INSERT INTO auth_systems_users (auth_system_id, user_id, data)
  SELECT 'password', users.id, users.password_digest
  FROM users
  WHERE users.password_digest IS NOT NULL;

ALTER TABLE users DROP COLUMN password_digest;
