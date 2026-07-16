import React, { useState } from 'react';
import './Login.css';
import { Sun, Moon, X } from 'lucide-react';

export default function Login({ onLoginSuccess }) {
  const [username, setUsername] = useState('');
  const [password, setPassword] = useState('');
  const [showPwd, setShowPwd] = useState(false);
  const [error, setError] = useState('');

  const handleLogin = () => {
    if (username && password) {
      setError('');
      onLoginSuccess();
    } else {
      setError('Please enter both username and password.');
    }
  };

  return (
    <div className="login-overlay glass-panel">
      <button className="modal-close-btn" onClick={() => {}}>
        <X size={22} />
      </button>

      <div className="login-card glass-panel">
        <h2>Sign in to ISL Dashboard</h2>

        <input
          type="text"
          placeholder="Username"
          value={username}
          onChange={e => setUsername(e.target.value)}
          className="login-input"
        />
        <div className="pwd-wrapper">
          <input
            type={showPwd ? 'text' : 'password'}
            placeholder="Password"
            value={password}
            onChange={e => setPassword(e.target.value)}
            className="login-input"
          />
          <button
            type="button"
            className="show-pwd-btn"
            onClick={() => setShowPwd(!showPwd)}
          >
            {showPwd ? <Sun size={16} /> : <Moon size={16} />}
          </button>
        </div>

        {error && <p className="login-error">{error}</p>}

        <button className="login-submit btn-primary" onClick={handleLogin}>
          Login
        </button>
      </div>
    </div>
  );
}
