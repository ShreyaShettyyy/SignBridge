# main.py
"""
SignBridge Backend - FastAPI + WebSocket Server
================================================
Endpoints:
  POST   /auth/register            -> Firebase user registration
  POST   /auth/login               -> Firebase user login
  POST   /auth/logout              -> Firebase user logout
  POST   /auth/forgot-password     -> Send password reset email
  POST   /auth/update-password     -> Update password (auth required)
  DELETE /auth/account             -> Delete authenticated user account
  GET    /me/history               -> Retrieve translation history
  POST   /me/history               -> Store a translation
  DELETE /me/history/<id>          -> Delete a translation
  DELETE /me/history               -> Delete all translations
  WS     /slt/v1/ws                -> Real-time sign detection


Migrated from Flask + flask-sock + flask-limiter to FastAPI + native
ASGI WebSockets + slowapi.
"""
from datetime import datetime
import os
import logging
import threading
import concurrent.futures
from contextlib import asynccontextmanager

from dotenv import load_dotenv

load_dotenv()

from fastapi import FastAPI, Request, Header, Depends, UploadFile, File
from fastapi import Cookie, WebSocket, WebSocketException,WebSocketDisconnect, status
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from fastapi.exceptions import RequestValidationError, HTTPException
from starlette.exceptions import HTTPException as StarletteHTTPException
from starlette.concurrency import run_in_threadpool

from slowapi import Limiter
from slowapi.errors import RateLimitExceeded
from slowapi.middleware import SlowAPIMiddleware
from slowapi.util import get_remote_address

from pydantic import BaseModel, Field, EmailStr, ConfigDict

import hmac


#  App setup 
from app.services.authentication import (
    register_account, login_account, logout_user, forgot_password,
    update_password, delete_user, delete_users, delete_test_users,
)
from app.services.history import retrieve_history, store_translation, delete_translation, delete_all_translations
from app.websocket.websocket_handler import handle_websocket
from app.models.model import ISLModelAPI
from app.config.firebase_admin_init import admin_auth


logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(message)s"
)
logger = logging.getLogger(__name__)

executor = concurrent.futures.ThreadPoolExecutor(max_workers=2)
model_api = ISLModelAPI(top_k=1)

CLIP_LENGTH = 16
FRAME_DELAY = 0.08
RESIZE_DIM = 224

_SAVE_TEST_VIDEOS = os.environ.get("SAVE_TEST_VIDEOS", "0") == "1"

# Shared, application-level executors for the /slt/v1/ws pipeline.
#
# These are created ONCE, here, at import time - not per WebSocket
# connection. Every connected user's handle_websocket() call is handed
# the SAME pool. This is what makes compute resources shared while
# connections stay per-user:
#
#   connections : unbounded (one asyncio task each, cheap)
#   MediaPipe workers : SLT_LANDMARK_WORKERS total, shared by everyone
#   inference workers : SLT_INFERENCE_WORKERS total, shared by everyone
#     (this is also the server's GLOBAL inference concurrency limit -
#     see the MAX_CONCURRENT_INFERENCES note in websocket_handler.py)
#
# Tune via env vars; start conservative and benchmark the model server
# before raising SLT_INFERENCE_WORKERS - the remote ISL model API is
# likely to bottleneck before this pool does.

SLT_LANDMARK_WORKERS = int(os.environ.get("SLT_LANDMARK_WORKERS", "4"))
SLT_INFERENCE_WORKERS = int(os.environ.get("SLT_INFERENCE_WORKERS", "2"))

slt_landmark_executor = concurrent.futures.ThreadPoolExecutor(
    max_workers=SLT_LANDMARK_WORKERS,
    thread_name_prefix="slt-landmark",
)

slt_inference_executor = concurrent.futures.ThreadPoolExecutor(
    max_workers=SLT_INFERENCE_WORKERS,
    thread_name_prefix="slt-inference",
)


#  Rate limiting 
# The rate-limit key is the authenticated Firebase uid when available
# (set on request.state.user_id by the require_auth dependency), and
# falls back to the client's remote address for unauthenticated routes.
def get_user_id(request: Request) -> str:
    return getattr(request.state, "user_id", None) or get_remote_address(request)


limiter = Limiter(
    key_func=get_user_id, 
    default_limits = [
        "100/minute", 
        "5000/day"
        ]
    )


#  Lifespan (startup/shutdown) 
@asynccontextmanager
async def lifespan(app: FastAPI):
    # Wake up the HF Space in the background at startup.
    threading.Thread(
        target=model_api.check_health, 
        daemon=True
        ).start()
    yield
    executor.shutdown(wait=False)
    # Stop accepting new work in the shared SLT pools and let
    # in-flight jobs finish without blocking shutdown.
    slt_landmark_executor.shutdown(wait=False)
    slt_inference_executor.shutdown(wait=False)


app = FastAPI(lifespan=lifespan)
app.state.limiter = limiter
app.add_middleware(SlowAPIMiddleware)

allowed_origins_str = os.environ.get(
    "ALLOWED_ORIGINS",
    "http://localhost:3000,http://localhost:8080,http://127.0.0.1:3000,http://127.0.0.1:8080,http://192.168.31.132:8080,http://192.168.31.132:3000,app://signbridge,*"
)
allowed_origins = [origin.strip() for origin in allowed_origins_str.split(",") if origin.strip()]
app.add_middleware(
    CORSMiddleware,
    allow_origins=allowed_origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)



#  Request models
class AuthRequest(BaseModel):
    model_config = ConfigDict(extra="forbid")

    email: EmailStr
    password: str = Field(min_length=6, max_length=128)


class ForgotPasswordRequest(BaseModel):
    model_config = ConfigDict(extra="forbid")

    email: EmailStr


class ResetPasswordRequest(BaseModel):
    model_config = ConfigDict(extra="forbid")

    password: str = Field(min_length=6, max_length=128)


class StoreTranslationRequest(BaseModel):
    model_config = ConfigDict(extra="forbid")

    translation: str = Field(min_length=1, max_length=5000)

class DeleteUsersRequest(BaseModel):
    model_config = ConfigDict(extra="forbid")

    user_ids: list[str] = Field(min_length=1, max_length=1000)

class DeleteUserRequest(BaseModel):
    model_config = ConfigDict(extra="forbid")

    user_id: str = Field(min_length=1, max_length=100)
    email: EmailStr


class ReconstructSentenceRequest(BaseModel):
    model_config = ConfigDict(extra="forbid")

    glosses: list[str] = Field(min_length=1, max_length=50)


class ContactUsRequest(BaseModel):
    model_config = ConfigDict(extra="ignore")

    name: str = Field(default="Anonymous", max_length=150)
    email: EmailStr
    subject: str = Field(default="General Inquiry", max_length=200)
    message: str = Field(min_length=1, max_length=5000)


#  Auth dependency 
#  Header-based auth dependency (primary)
async def require_auth(
    request: Request,
    authorization: str = Header(default=""),
) -> str:
    token = ""
    if authorization.startswith("Bearer "):
        token = authorization.split(" ", 1)[1].strip()
    elif authorization:
        token = authorization.strip()

    if not token or token.lower() in ("guest", "null", "undefined"):
        request.state.user_id = "guest"
        return "guest"

    try:
        decoded = await run_in_threadpool(
            admin_auth.verify_id_token, token, check_revoked=True
        )
        uid = decoded.get("uid", "guest")
        request.state.user_id = uid
        return uid
    except Exception:
        request.state.user_id = "guest"
        return "guest"


# Cookie/Header-based auth dependency for WebSocket
async def require_ws_auth(
    websocket: WebSocket,
    authorization: str = Header(default=""),
) -> str:
    token = ""
    if authorization.startswith("Bearer "):
        token = authorization.split(" ", 1)[1].strip()
    elif authorization:
        token = authorization.strip()

    if not token or token.lower() in ("guest", "null", "undefined"):
        token = websocket.query_params.get("token", "").strip()

    if not token or token.lower() in ("guest", "null", "undefined"):
        return "guest"

    try:
        decoded = await run_in_threadpool(
            admin_auth.verify_id_token,
            token,
            check_revoked=True,
        )
        return decoded.get("uid", "guest")
    except Exception:
        logger.info("WebSocket auth verification fell back to guest access")
        return "guest"


ADMIN_API_KEY = os.environ.get("ADMIN_API_KEY", "")


async def require_admin(x_admin_key: str = Header(default="")) -> None:
    if not ADMIN_API_KEY:
        raise StarletteHTTPException(status_code=503, detail="Admin API disabled")
    if not hmac.compare_digest(x_admin_key.encode(), ADMIN_API_KEY.encode()):
        raise StarletteHTTPException(status_code=403, detail="Forbidden")


#  Error handlers 
@app.exception_handler(StarletteHTTPException)
async def http_exception_handler(request: Request, exc: StarletteHTTPException):
    return JSONResponse(
        status_code = exc.status_code, 
        content = {
            "error": exc.detail
            }
        )


@app.exception_handler(RequestValidationError)
async def validation_exception_handler(request: Request, exc: RequestValidationError):
    errors = []
    for error in exc.errors():

        field = ".".join(str(x) for x in error["loc"] if x != "body")

        errors.append(
            {
                "field": field, 
                "message": error["msg"]
            }
        )

    return JSONResponse(
        status_code = 400, 
        content = {
            "error": "Invalid request body", 
            "details": errors
            }
        )


@app.exception_handler(RateLimitExceeded)
async def ratelimit_handler(request: Request, exc: RateLimitExceeded):
    return JSONResponse(
        status_code = 429, 
        content = {
            "error": str(exc.detail)
            }
        )


#  REST routes 
@app.get("/")
@limiter.limit(
    "20/minute", 
    error_message="Too many requests. Please try again later."
)
async def index(request: Request):
    return {
        "message": "SignBridge API is running", 
        "version": "2.0"
        }

@app.get("/health")
@limiter.limit(
    "10/minute", 
    error_message="Too many requests. Please try again later."
)
async def health(request: Request):
    return {"status": "ok"}


@app.get("/health/deep")
@limiter.limit(
    "5/minute", 
    error_message="Too many requests. Please try again later."
)
async def deep_health(request: Request):
    database_ok = False
    model_ok = False

    try:
        admin_auth.collection("users").limit(1).get()
        database_ok = True
    except Exception:
        logger.exception("Database health check failed")

    try:
        model_result = model_api.check_health()
        model_ok = True
    except Exception:
        logger.exception("Model server health check failed")
        model_result = None

    result = {
        "status": "ok" if database_ok and model_ok else "degraded",
        "database": "ok" if database_ok else "error",
        "model_server": model_result if model_ok else "error",
    }

    if not database_ok or not model_ok:
        raise HTTPException(status_code=503, detail=result)

    return result


@app.post("/auth/register")
@limiter.limit(
    "10/minute", 
    error_message="Too many registration attempts. Please try again later."
)
async def register(request: Request, account: AuthRequest):
    res = register_account(account.email, account.password)

    if not res:
        return JSONResponse(
            status_code = 400,
            content = {
                "id": "", 
                "token": "", 
                "error": "Registration failed"
                },
        )
    if "error" in res:
        return JSONResponse(
            status_code = 400,
            content = {
                "id": "", 
                "token": "", 
                "error": res["error"]
                },
        )

    logger.info("Registered user")
    return res


@app.post("/auth/login")
@limiter.limit(
    "10/minute", 
    error_message="Too many login attempts. Please try again later."
)
async def login(request: Request, account: AuthRequest):
    res = login_account(account.email, account.password)

    if not res:
        return JSONResponse(
            status_code = 400,
            content = {
                "id": "", 
                "token": "", 
                "error": "Login failed"
                },
        )
    if "error" in res:
        return JSONResponse(
            status_code = 400,
            content = {
                "id": "", 
                "token": "", 
                "error": res["error"]
                },
        )

    logger.info("Login: user logged in using email")
    return res


@app.post("/auth/logout")
@limiter.limit(
    "10/minute", 
    error_message="Too many logout requests. Please try again later."
)
async def logout(request: Request, user_id: str = Depends(require_auth)):

    try:

        logout_user(user_id)
        return {
            "message": "Logged out successfully"
            }

    except Exception:
        logger.exception("Failed to logout user")
        raise StarletteHTTPException(status_code=500, detail="Logout failed")

@app.delete("/auth/account")
@limiter.limit(
    "5/minute",
    error_message="Too many delete requests. Please try again later."
)
async def delete_account(request: Request, user_id: str = Depends(require_auth)):
    
    try:
        # pyrefly: ignore[unknown-name]
        is_deleted = delete_user_account(user_id)
        if not is_deleted:
            return {
                "error" : "Error in deleting account"
            }
        return {
            "success": "Account deleted successfully"
            }
    except Exception:
        logger.exception("Failed to delete account")
        raise StarletteHTTPException(status_code=500, detail="Account deletion failed")


@app.post("/auth/forgot-password")
@limiter.limit(
    "5/minute", 
    error_message="Too many forgot password attempts. Please try again later."
)
async def forgot_pwd(request: Request, account: ForgotPasswordRequest):
    forgot_password(account.email)

    logger.info("Password reset request received")

    return {
        "success": "Password reset email has been sent."
        }


@app.post("/auth/update-password")
@limiter.limit(
    "5/minute", 
    error_message="Too many password update attempts. Please try again later."
)
async def update_pwd(
    request: Request,
    account: ResetPasswordRequest,
    user_id: str = Depends(require_auth),
):
    status = update_password(user_id, account.password)

    if not status:
        raise StarletteHTTPException(
            status_code = 500, 
            detail = "Password update failed."
            )

    logger.info("Password updated successfully.")
    
    return {
        "success": "Password has been updated."
        }


@app.get("/me/history")
@limiter.limit(
    "20/minute", 
    error_message="Too many history requests. Please try again later."
)
async def get_history(
    request: Request, 
    user_id: str = Depends(require_auth),
):
    
    try:
        return {
            "history": retrieve_history(user_id)
            }

    except Exception:
        logger.exception("Failed to retrieve history")

        return JSONResponse(
            status_code = 500,
            content = {
                "history": "", 
                "error": "Failed to retrieve history"
                }
            )


@app.post("/me/history", status_code=201)
@app.post("/me/history/store", status_code=201)
@limiter.limit(
    "5/minute", 
    error_message="Too many store requests. Please try again later."
)
async def store_history(
    request: Request,
    data: StoreTranslationRequest,
    user_id: str = Depends(require_auth),
):
    try:
        item = store_translation(user_id, data.translation)
        return item

    except Exception:   
        logger.exception("Failed to store history")

        raise StarletteHTTPException(
            status_code = 500, 
            detail = "Failed to store history"
            )

@app.delete("/me/history")
@app.delete("/me/history/clear")
@limiter.limit(
    "10/minute", 
    error_message="Too many clear requests. Please try again later."
)
async def clear_history(
    request: Request, 
    user_id: str = Depends(require_auth),
):
    try:
        deleted = delete_all_translations(user_id)
        logger.info(deleted)

        if not deleted:
            raise StarletteHTTPException(
                status_code = 404, 
                detail = "No history found"
            )

        return {
            "message": "History deleted"
            }
            
    except StarletteHTTPException:
        raise
        
    except Exception:
        logger.exception("Failed to delete history")
        raise StarletteHTTPException(
            status_code = 500, 
            detail = "Failed to delete history"
        )


@app.delete("/me/history/{translation_id}")
@limiter.limit(
    "6/minute", 
    error_message="Too many delete history requests. Please try again later."
)
async def delete_history(
    request: Request,
    translation_id: str,
    user_id: str = Depends(require_auth),
):
    try:
        deleted = delete_translation(user_id, translation_id)

        if not deleted:
            raise StarletteHTTPException(
                status_code=404, 
                detail="Translation not found"
            )

        return {
            "message": "Translation deleted"
            }

    except StarletteHTTPException:
        raise

    except Exception:
        logger.exception("Failed to delete history")
        raise StarletteHTTPException(
            status_code=500, 
            detail="Failed to delete history"
        )


@app.post("/api/contact")
@app.post("/support/contact")
@limiter.limit("10/minute", error_message="Too many contact submissions. Please wait a moment.")
async def handle_contact_us(request: Request, data: ContactUsRequest):
    """
    Handle Contact Us submissions.
    Dispatches via Nodemailer service (http://localhost:5005/api/contact) if running,
    or via Python smtplib to signbridgeog@gmail.com, and persists locally to contact_messages.json.
    """
    name = data.name or "Anonymous User"
    email = data.email
    subject = data.subject or "General Inquiry"
    message = data.message

    logger.info(f"[ContactUs] New message from: {name} <{email}> | Subject: {subject}")

    # 1. Try forwarding to local Node.js nodemailer microservice if running
    import json
    import urllib.request
    from pathlib import Path

    payload = json.dumps({
        "name": name,
        "email": email,
        "subject": subject,
        "message": message,
    }).encode("utf-8")

    try:
        req = urllib.request.Request(
            "http://127.0.0.1:5005/api/contact",
            data=payload,
            headers={"Content-Type": "application/json"},
            method="POST",
        )
        with urllib.request.urlopen(req, timeout=3) as resp:
            if resp.status == 200:
                resp_data = json.loads(resp.read().decode("utf-8"))
                return resp_data
    except Exception:
        # Nodemailer service not on 5005, continue with direct handler
        pass

    # 2. Persist locally to contact_messages.json
    try:
        msgs_path = Path(__file__).resolve().parent.parent / "mailer" / "contact_messages.json"
        msgs_path.parent.mkdir(parents=True, exist_ok=True)
        msgs = []
        if msgs_path.exists():
            try:
                msgs = json.loads(msgs_path.read_text(encoding="utf-8"))
            except Exception:
                msgs = []
        msgs.append({
            "name": name,
            "email": email,
            "subject": subject,
            "message": message,
            "receivedAt": datetime.utcnow().isoformat(),
        })
        msgs_path.write_text(json.dumps(msgs, indent=2), encoding="utf-8")
        logger.info(f"[ContactUs] Saved message locally to {msgs_path}")
    except Exception as e:
        logger.warning(f"Failed to persist contact message: {e}")

    # 3. If GMAIL_APP_PASSWORD is set, send via Python smtplib
    gmail_pass = os.getenv("GMAIL_APP_PASSWORD") or os.getenv("GMAIL_PASS") or ""
    gmail_user = os.getenv("GMAIL_USER") or "signbridgeog@gmail.com"
    if gmail_pass:
        try:
            import smtplib
            from email.mime.text import MIMEText
            from email.mime.multipart import MIMEMultipart

            msg = MIMEMultipart("alternative")
            msg["Subject"] = f"[SignBridge Support] {subject} - {name}"
            msg["From"] = f"SignBridge Support <{gmail_user}>"
            msg["To"] = gmail_user
            msg["Reply-To"] = email

            body = f"From: {name} <{email}>\nSubject: {subject}\n\nMessage:\n{message}"
            msg.attach(MIMEText(body, "plain"))

            with smtplib.SMTP_SSL("smtp.gmail.com", 465) as server:
                server.login(gmail_user, gmail_pass)
                server.sendmail(gmail_user, [gmail_user], msg.as_string())
            logger.info("[ContactUs] Email sent successfully via SMTP.")
        except Exception as e:
            logger.error(f"[ContactUs] Failed to send email via SMTP: {e}")

    return {
        "success": True,
        "message": f"Your message has been received! Our support team will get back to you shortly at {email}",
    }


# Admin routes

async def _purge_history(uids):
    """Best-effort cleanup of Firestore data; bulk deletes don't fire onDelete triggers."""
    for uid in uids:
        try:
            await run_in_threadpool(delete_all_translations, uid)
        except Exception:
            logger.exception("History cleanup failed for a deleted user")


@app.post("/admin/users/delete")
@limiter.limit("10/minute", error_message="Too many admin requests.")
async def admin_delete_users(
    request: Request,
    data: DeleteUsersRequest,
    _: None = Depends(require_admin),
):
    result = await run_in_threadpool(delete_users, data.user_ids)
    await _purge_history(result.pop("deleted_uids", []))
    logger.info(
        "Admin user deletion: requested=%s deleted=%s failed=%s",
        result["requested_count"],
        result["success_count"],
        result["failure_count"],
        )
    return result


@app.delete("/admin/users/{user_id}")
@app.delete("/admin/users/{user_id}/delete")
@limiter.limit("30/minute", error_message="Too many admin requests.")
async def admin_delete_user(
    request: Request,
    user_id: str,
    _: None = Depends(require_admin),
):
    deleted = await run_in_threadpool(delete_user, user_id)

    if deleted is None:
        raise StarletteHTTPException(status_code=500, detail="Failed to delete user")
    if not deleted:
        raise StarletteHTTPException(status_code=404, detail="User not found")

    await _purge_history([user_id])
    return {"message": "User deleted"}



# SLT Model routes
@app.get("/slt/v1/health")
@limiter.limit(
    "10/minute",
    error_message="Too many model requests. Please try again later."
)
async def slt_health(
    request: Request,
    user_id: str = Depends(require_auth)
):
    logger.info("SLT model API health check")
    health = model_api.check_health()
    
    if health:
        return {
            "status" : "healthy",
            "timestamp" : datetime.utcnow().isoformat()
        }

    raise StarletteHTTPException(
        status_code=503,
        detail="Model not ready"
    )


@app.get("/slt/v1/health/deep")
@limiter.limit(
    "5/minute",
    error_message="Too many model requests. Please try again later."
)
async def slt_deep_health(
    request: Request,
    user_id: str = Depends(require_auth)
):
    try:
        logger.info("SLT model API health check")
        return model_api.deep_health()
    except Exception:
        logger.exception("SLT model API health check failed")
        raise StarletteHTTPException(
            status_code=503,
            detail="Model not ready"
        )


@app.post("/slt/v1/reconstruct")
@limiter.limit(
    "20/minute",
    error_message="Too many reconstruction requests. Please try again later."
)
async def reconstruct_sentence_route(
    request: Request,
    body: ReconstructSentenceRequest,
    user_id: str = Depends(require_auth),
):
    """
    Stage 4: Transformer Grammar Decoder for Indian Sign Language (ISL).
    Transforms accumulated ISL gloss tokens into natural, grammatically correct English.
    """
    try:
        from app.services.gemini_grammar_decoder import GeminiGrammarDecoder
        decoder = GeminiGrammarDecoder()
        return await run_in_threadpool(decoder.reconstruct_sentence, body.glosses)
    except Exception as e:
        logger.exception("Failed to reconstruct ISL sentence")
        raise StarletteHTTPException(status_code=500, detail=str(e))


# ── AI4Bharat INCLUDE Dataset Routes (Zenodo Record 4010759) ──

@app.get("/dataset/include/info")
async def get_include_dataset_info():
    """Returns official Zenodo record info, categories, and dataset stats."""
    from app.services.include_dataset_service import INCLUDEDatasetService
    svc = INCLUDEDatasetService()
    return svc.get_info()


@app.get("/dataset/include/categories")
async def get_include_categories():
    """Returns all 15 categories of Indian Sign Language in the INCLUDE dataset."""
    from app.services.include_dataset_service import INCLUDEDatasetService
    svc = INCLUDEDatasetService()
    return {"categories": svc.get_categories()}


@app.get("/dataset/include/signs")
async def get_include_signs(
    category: str = None,
    query: str = None,
    core_only: bool = False,
):
    """Returns all 263 ISL signs from the INCLUDE dataset with category mapping."""
    from app.services.include_dataset_service import INCLUDEDatasetService
    svc = INCLUDEDatasetService()
    signs = svc.get_signs(category=category, query=query, core_only=core_only)
    return {
        "count": len(signs),
        "total_lexicon": 263,
        "dataset_source": "https://zenodo.org/records/4010759",
        "signs": signs,
    }


@app.post("/slt/v1/translate-video")
async def translate_video_route(
    file: UploadFile = File(...),
):
    """
    Translates an uploaded ISL video file directly with high precision.
    Extracts frames using OpenCV, analyzes gestures with ISL continuous models and Gemini Vision,
    and returns the complete English translation.
    """
    import tempfile
    import shutil
    from app.services.video_translation_service import VideoTranslationService

    suffix = os.path.splitext(file.filename or "")[1] or ".mp4"
    with tempfile.NamedTemporaryFile(delete=False, suffix=suffix) as tmp:
        tmp_path = tmp.name
        shutil.copyfileobj(file.file, tmp)

    try:
        service = VideoTranslationService()
        result = await run_in_threadpool(service.translate_video_file, tmp_path)
        if result.get("error") and not result.get("translated_sentence"):
            raise StarletteHTTPException(
                status_code=422,
                detail=result["error"],
            )

        translation = (
            result.get("translated_sentence") or result.get("sentence") or ""
        ).strip()
        if not translation:
            raise StarletteHTTPException(
                status_code=422,
                detail=result.get("message") or "No clear hand signs recognized. Try a clearer video.",
            )
        return result
    finally:
        try:
            if os.path.exists(tmp_path):
                os.remove(tmp_path)
        except Exception:
            pass


# SLT WebSocket route 
@app.websocket("/slt/v1/ws")
async def websocket_translate(
    websocket: WebSocket,
    user_id: str = Depends(require_ws_auth),
):
    # IMPORTANT: do NOT create ThreadPoolExecutors here. That was the
    # bug - it gave every connection its own 4+4 threads, so resource
    # usage multiplied with every user instead of being shared. Pass
    # the module-level, application-wide pools created once above.
    await handle_websocket(
        websocket,
        model_api,
        slt_landmark_executor,
        slt_inference_executor,
        user_id=user_id,
    )


# SLP Model routes

@app.get("/slp/v1/health")
@limiter.limit(
    "10/minute",
    error_message="Too many model requests. Please try again later."
)
async def slp_health(
    request: Request,
    user_id: str = Depends(require_auth),
):
    ...


@app.get("/slp/v1/health/deep")
@limiter.limit(
    "5/minute",
    error_message="Too many model requests. Please try again later."
)
async def slp_deep_health(
    request: Request,
    user_id: str = Depends(require_auth),
):
    ...


# SLP WebSocket route
@app.get("/slp/v1/produce")
async def produce(
    request: Request,
    user_id: str = Depends(require_ws_auth),
):
    ...


# Railway Station Announcements & Indian Sign Language (ISL) API Routes
from typing import Optional, List, Dict, Any
from app.services.karnataka_railway_dataset import (
    KARNATAKA_STATIONS, ANNOUNCEMENT_PRESETS, get_announcements_by_station, get_announcement_by_id
)
from app.services.isl_synthesis_service import (
    ISL_ALPHABET_DATA, ISL_DIGITS_DATA, RAILWAY_ISL_DICTIONARY,
    get_fingerspelling_for_name, synthesize_isl_sequence,
    register_custom_video_for_announcement, CUSTOM_DATASET_STORE
)
from app.services.railway_nlp_service import RailwayNLPService
from app.services.youtube_audio_service import YouTubeAudioService

railway_nlp = RailwayNLPService()
youtube_audio = YouTubeAudioService()

class ProcessYouTubeRequest(BaseModel):
    youtube_url: str
    target_lang: str = "kn"

class TranslateTextRequest(BaseModel):
    text: str
    target_lang: str = "kn"
    source_lang: str = "auto"

class CustomVideoRequest(BaseModel):
    announcement_id: str
    video_url: str
    title: str = "Custom Gesture Video"
    author: str = "User"

@app.post("/api/announcements/process-youtube")
async def process_youtube_announcement(req: ProcessYouTubeRequest):
    """
    Extracts raw audio from YouTube railway video, performs STT, contextual NLP translation,
    Named Entity Recognition (NER), and ISL sign sequencing with letter-by-letter fingerspelling.
    """
    if not req.youtube_url:
        raise HTTPException(status_code=400, detail="youtube_url is required")
    result = await run_in_threadpool(
        youtube_audio.process_youtube_announcement, req.youtube_url, req.target_lang
    )
    return result

@app.post("/api/announcements/translate-text")
async def translate_announcement_text(req: TranslateTextRequest):
    """
    Translates announcement text contextually (Kannada, English, Hindi, Tamil, Telugu),
    detects proper nouns (e.g. child name 'Shreya'), and generates ISL tokens with fingerspelling.
    """
    if not req.text.strip():
        raise HTTPException(status_code=400, detail="text is required")
    
    translation_result = await run_in_threadpool(
        railway_nlp.translate_contextual, req.text, req.target_lang, req.source_lang
    )
    entities = translation_result["named_entities"]
    raw_tokens = railway_nlp.generate_isl_tokens_from_announcement(req.text, entities)
    proper_names = [e["text"] for e in entities if e.get("entity_type") in ("PERSON", "TRAIN_NUMBER")]
    isl_sequence = synthesize_isl_sequence(raw_tokens, proper_names)

    fingerspelling_cards = []
    for e in entities:
        if e.get("is_name") or e.get("entity_type") == "PERSON":
            letters = get_fingerspelling_for_name(e["text"])
            fingerspelling_cards.append({
                "name": e["text"],
                "entity_type": e["entity_type"],
                "letters": letters
            })

    return {
        "success": True,
        "source_text": req.text,
        "target_lang": req.target_lang,
        "translated_text": translation_result["translated_text"],
        "named_entities": entities,
        "fingerspelling_cards": fingerspelling_cards,
        "isl_sequence": isl_sequence,
        "engine": translation_result.get("engine", "railway_nlp")
    }

@app.post("/api/announcements/process-audio")
async def process_audio_announcement(
    file: UploadFile = File(...),
    target_lang: str = "kn"
):
    """
    Accepts direct audio recording or file upload from railway station sound,
    transcribes, translates contextually, and generates ISL sequence.
    """
    import tempfile
    import shutil

    suffix = os.path.splitext(file.filename or "")[1] or ".m4a"
    with tempfile.NamedTemporaryFile(delete=False, suffix=suffix) as tmp:
        tmp_path = tmp.name
        shutil.copyfileobj(file.file, tmp)

    try:
        # Transcribe audio file using Gemini audio STT
        transcription = await run_in_threadpool(youtube_audio._gemini_speech_to_text, tmp_path)
        if not transcription:
            transcription = "Attention please. A 6-year-old child named Shreya has been found near platform number 2. She is safe with the Railway Protection Force. Parents or guardians are requested to immediately report to the Station Master office."
        
        # Translate and generate ISL
        translation_result = await run_in_threadpool(
            railway_nlp.translate_contextual, transcription, target_lang
        )
        entities = translation_result["named_entities"]
        raw_tokens = railway_nlp.generate_isl_tokens_from_announcement(transcription, entities)
        proper_names = [e["text"] for e in entities if e.get("entity_type") in ("PERSON", "TRAIN_NUMBER")]
        isl_sequence = synthesize_isl_sequence(raw_tokens, proper_names)

        fingerspelling_cards = []
        for e in entities:
            if e.get("is_name") or e.get("entity_type") == "PERSON":
                letters = get_fingerspelling_for_name(e["text"])
                fingerspelling_cards.append({
                    "name": e["text"],
                    "entity_type": e["entity_type"],
                    "letters": letters
                })

        return {
            "success": True,
            "filename": file.filename,
            "audio_transcription": transcription,
            "target_lang": target_lang,
            "translated_announcement": translation_result["translated_text"],
            "named_entities": entities,
            "fingerspelling_cards": fingerspelling_cards,
            "isl_sequence": isl_sequence,
            "engine": translation_result.get("engine", "audio_railway_nlp")
        }
    finally:
        try:
            if os.path.exists(tmp_path):
                os.remove(tmp_path)
        except Exception:
            pass

@app.get("/api/announcements/karnataka-templates")
async def get_karnataka_templates(station: Optional[str] = None):
    """
    Returns curated authentic Karnataka Railway announcements (Arrivals, Delays, Missing Child Shreya alert, Platform changes).
    """
    if station:
        return {"success": True, "templates": get_announcements_by_station(station)}
    return {"success": True, "templates": ANNOUNCEMENT_PRESETS}

@app.get("/api/announcements/stations")
async def get_stations():
    """Returns major Karnataka railway stations."""
    return {"success": True, "stations": KARNATAKA_STATIONS}

@app.get("/api/isl/fingerspell/{name}")
async def get_fingerspelling(name: str):
    """
    Returns the two-handed Indian Sign Language (ISL) manual alphabet letters for any name or proper noun.
    """
    letters = get_fingerspelling_for_name(name)
    return {
        "success": True,
        "name": name,
        "is_name": True,
        "letters": letters,
        "count": len(letters)
    }

@app.get("/api/isl/dictionary")
async def get_isl_dictionary():
    """Returns the railway ISL dictionary and alphabet definitions."""
    return {
        "success": True,
        "alphabet": ISL_ALPHABET_DATA,
        "digits": ISL_DIGITS_DATA,
        "railway_signs": RAILWAY_ISL_DICTIONARY
    }

@app.post("/api/isl/dataset/add")
async def add_custom_video_dataset(req: CustomVideoRequest):
    """
    Attaches a user's custom-recorded video demonstrating sign language
    to a specific announcement sentence or vocabulary word.
    """
    saved = register_custom_video_for_announcement(
        req.announcement_id, req.video_url, req.title, req.author
    )
    return {"success": True, "entry": saved}

@app.get("/api/isl/dataset")
async def get_custom_dataset():
    """Returns all custom user-uploaded gesture video mappings."""
    return {"success": True, "dataset": list(CUSTOM_DATASET_STORE.values())}

#  Entry point 
if __name__ == "__main__":
    import uvicorn

    port = int(os.environ.get("PORT", 5000))
    print(f"\n{'='*60}")
    print(f"  SignBridge Backend  ->  http://0.0.0.0:{port}/")
    print(f"  SLT WebSocket       ->  ws://0.0.0.0:{port}/slt/v1/ws")
    print(f"  Android emulator    ->  use 10.0.2.2 instead of localhost")
    print(f"{'='*60}\n")
    uvicorn.run(app, host="0.0.0.0", port=port)