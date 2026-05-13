-- Creates logins with a temporary password
CREATE LOGIN Chefs_table_user WITH PASSWORD = 'Password1234!';
CREATE LOGIN Reservations_table_user WITH PASSWORD = 'Password1234!';
GO

-- Creates database users logins
CREATE USER Chefs_table_user FOR LOGIN Chefs_table_user;
CREATE USER Reservations_table_user FOR LOGIN Reservations_table_user;
GO

-- Assigns roles
ALTER ROLE db_accessadmin ADD MEMBER Chefs_table_user;
ALTER ROLE db_datareader ADD MEMBER Reservations_table_user;
ALTER ROLE db_datawriter ADD MEMBER Reservations_table_user;
GO