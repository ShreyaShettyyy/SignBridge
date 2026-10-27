const express = require('express');
const nodemailer = require('nodemailer');
const cors = require('cors');
const fs = require('fs');
const path = require('path');
require('dotenv').config({ path: path.join(__dirname, '..', '.env') });
require('dotenv').config(); // also loads local .env if present

const app = express();
const PORT = process.env.MAILER_PORT || 5005;

app.use(cors());
app.use(express.json());

const GMAIL_USER = process.env.GMAIL_USER || 'signbridgeog@gmail.com';
const GMAIL_PASS = process.env.GMAIL_APP_PASSWORD || process.env.GMAIL_PASS || '';

// Transporter configuration
function createTransporter() {
  if (!GMAIL_PASS) {
    return null;
  }
  return nodemailer.createTransport({
    service: 'gmail',
    auth: {
      user: GMAIL_USER,
      pass: GMAIL_PASS,
    },
  });
}

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({
    status: 'ok',
    service: 'SignBridge Nodemailer Service',
    gmail: GMAIL_USER,
    configured: Boolean(GMAIL_PASS),
  });
});

// Contact Us endpoint
app.post('/api/contact', async (req, res) => {
  try {
    const { name, email, subject, message } = req.body;

    if (!email || !message) {
      return res.status(400).json({
        success: false,
        error: 'Email and message fields are required.',
      });
    }

    const submissionTime = new Date().toISOString();
    const contactEntry = {
      name: name || 'Anonymous',
      email,
      subject: subject || 'General Inquiry',
      message,
      receivedAt: submissionTime,
    };

    console.log(`[ContactUs] New message from: ${name} <${email}>`);
    console.log(`[ContactUs] Subject: ${subject}`);
    console.log(`[ContactUs] Message: ${message}`);

    // Persist to local JSON file so no messages are ever lost
    const messagesFile = path.join(__dirname, 'contact_messages.json');
    let messages = [];
    if (fs.existsSync(messagesFile)) {
      try {
        messages = JSON.parse(fs.readFileSync(messagesFile, 'utf8'));
      } catch (err) {
        messages = [];
      }
    }
    messages.push(contactEntry);
    fs.writeFileSync(messagesFile, JSON.stringify(messages, null, 2));

    const transporter = createTransporter();

    if (transporter) {
      // Send real email via Nodemailer
      const mailOptions = {
        from: `"SignBridge Support" <${GMAIL_USER}>`,
        to: GMAIL_USER,
        replyTo: email,
        subject: `[SignBridge Support] ${subject || 'New Contact Form Message'} - ${name || email}`,
        html: `
          <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; padding: 20px; border: 1px solid #e0e0e0; borderRadius: 12px;">
            <div style="background-color: #1E2158; padding: 16px; border-radius: 8px; text-align: center;">
              <h2 style="color: #ffffff; margin: 0;">SignBridge Contact Us</h2>
            </div>
            <div style="padding: 20px 0;">
              <p><strong>From:</strong> ${name || 'N/A'} (&lt;${email}&gt;)</p>
              <p><strong>Subject:</strong> ${subject || 'General Inquiry'}</p>
              <p><strong>Received At:</strong> ${submissionTime}</p>
              <hr style="border: none; border-top: 1px solid #eee; margin: 20px 0;" />
              <p><strong>Message:</strong></p>
              <div style="background-color: #f8f9fe; padding: 16px; border-radius: 8px; border-left: 4px solid #4B6CF7; white-space: pre-wrap;">
                ${message}
              </div>
            </div>
            <div style="font-size: 12px; color: #888; text-align: center; border-top: 1px solid #eee; padding-top: 12px;">
              Sent via SignBridge App Support System
            </div>
          </div>
        `,
      };

      await transporter.sendMail(mailOptions);
      console.log(`[ContactUs] Email successfully sent to ${GMAIL_USER}`);
      return res.json({
        success: true,
        message: 'Your message has been sent to our support team.',
      });
    } else {
      // Password not yet configured
      console.log('[ContactUs] Gmail password not yet configured. Message saved locally to contact_messages.json');
      return res.json({
        success: true,
        message: 'Your message has been received! Our support team will get back to you shortly.',
      });
    }
  } catch (error) {
    console.error('[ContactUs] Error handling contact submission:', error);
    return res.status(500).json({
      success: false,
      error: 'Failed to send message. Please try again or email us directly at ' + GMAIL_USER,
    });
  }
});

app.listen(PORT, () => {
  console.log(`SignBridge Nodemailer Service is running on http://localhost:${PORT}`);
  console.log(`Target Gmail: ${GMAIL_USER}`);
  if (!GMAIL_PASS) {
    console.log(`Note: GMAIL_APP_PASSWORD is not set yet. Submissions will be logged and saved to contact_messages.json.`);
  } else {
    console.log(`Gmail App Password is configured. Real emails will be dispatched.`);
  }
});
