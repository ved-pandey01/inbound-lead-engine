-- Inbound Lead Engine: SQLite table design
-- Create the database with: sqlite3 leads.db < schema.sql

CREATE TABLE leads (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  full_name TEXT,
  company TEXT,
  job_title TEXT,
  linkedin_url TEXT UNIQUE,
  email TEXT,
  lead_score INTEGER,
  score_reasoning TEXT,
  tier TEXT,
  status TEXT DEFAULT 'New',
  contacted_at TEXT,
  replied_at TEXT,
  created_at TEXT DEFAULT CURRENT_TIMESTAMP,
  updated_at TEXT DEFAULT CURRENT_TIMESTAMP
);
