-- --- reworked in migration 05 -----------------------------------------------
-- 
-- ALTER TABLE users ADD COLUMN password_hash text;
-- ALTER TABLE users ADD CONSTRAINT one_password CHECK (password_hash IS NULL OR password_digest IS NULL);
-- 
-- ALTER TABLE api_clients ADD COLUMN password_hash text;
-- ALTER TABLE api_clients ADD CONSTRAINT one_password CHECK (password_hash IS NULL OR password_digest IS NULL);
--  
-- 
--- users table fixes ---------------------------------------------------------

-- duplicate, there is also a unique constraint / index
DROP INDEX index_users_on_login; 

-- do not allow UUIDs in the login field
ALTER TABLE USERS ADD CONSTRAINT  login_not_uuid CHECK (login !~* E'^[[:xdigit:]]{8}-([[:xdigit:]]{4}-){3}[[:xdigit:]]{12}$');


