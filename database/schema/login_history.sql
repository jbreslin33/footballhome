-- Login History Table
-- Tracks all login instances for audit and security purposes

CREATE TABLE IF NOT EXISTS login_history (
    id SERIAL PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    login_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    ip_address VARCHAR(45),  -- IPv6 can be up to 45 chars
    user_agent TEXT,
    success BOOLEAN NOT NULL DEFAULT true,
    
    -- Index for efficient queries
    INDEX idx_login_history_user_id (user_id),
    INDEX idx_login_history_login_time (login_time)
);

-- Comments
COMMENT ON TABLE login_history IS 'Tracks all login attempts for security auditing';
COMMENT ON COLUMN login_history.user_id IS 'Reference to the user who logged in';
COMMENT ON COLUMN login_history.login_time IS 'Timestamp when login occurred';
COMMENT ON COLUMN login_history.ip_address IS 'IP address of the login attempt';
COMMENT ON COLUMN login_history.user_agent IS 'Browser user agent string';
COMMENT ON COLUMN login_history.success IS 'Whether the login was successful';
