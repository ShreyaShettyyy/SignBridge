const sqlite3 = require('sqlite3').verbose();
const path = require('path');

const dbPath = process.env.DB_PATH || path.resolve(__dirname, 'users.db');
const db = new sqlite3.Database(dbPath, (err) => {
  if (err) {
    console.error('Error connecting to database:', err.message);
  } else {
    console.log('Connected to the SQLite database.');
    db.serialize(() => {
      // Create users table
      db.run(`CREATE TABLE IF NOT EXISTS users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        email TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL,
        full_name TEXT
      )`);

      // Migration: Add full_name to existing users table if it doesn't exist
      db.run(`ALTER TABLE users ADD COLUMN full_name TEXT`, (err) => {
        // Ignore error if column already exists
        if (err && !err.message.includes('duplicate column name')) {
          // Log other errors if any, but ignore "duplicate column name"
        }
      });

      // Create password_resets table
      db.run(`CREATE TABLE IF NOT EXISTS password_resets (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        email TEXT NOT NULL,
        otp TEXT NOT NULL,
        expires_at INTEGER NOT NULL
      )`);
    });
  }
});

module.exports = db;
