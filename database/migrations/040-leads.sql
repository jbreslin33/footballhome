-- 040-leads.sql: Meta lead gen form submissions
CREATE TABLE IF NOT EXISTS leads (
  id          SERIAL PRIMARY KEY,
  leadgen_id  TEXT UNIQUE NOT NULL,
  form_id     TEXT NOT NULL,
  page_id     TEXT,
  ad_id       TEXT,
  name        TEXT,
  email       TEXT,
  phone       TEXT,
  raw_fields  JSONB,
  created_at  TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
