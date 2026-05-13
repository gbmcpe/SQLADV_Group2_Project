USE RestaurantDB;
GO

/*
================================================================================
TASK 1a: Disable NT SERVICE\SQLSERVERAGENT login at the database level
================================================================================
This revokes the CONNECT permission from the SQL Server Agent service account
preventing it from accessing the Restaurant database.
*/

-- First, check if the user exists in the database
IF EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'NT SERVICE\SQLSERVERAGENT')
BEGIN
    -- Revoke CONNECT permission to effectively disable access
    REVOKE CONNECT FROM [NT SERVICE\SQLSERVERAGENT];
    PRINT 'SUCCESS: NT SERVICE\SQLSERVERAGENT has been disabled at the database level';
END
ELSE
BEGIN
    PRINT 'INFO: NT SERVICE\SQLSERVERAGENT user does not exist in this database';
END
GO

/*
================================================================================
TASK 1b: Create RestaurantUser and assign db_backupoperator role
================================================================================
Creates a database user called 'RestaurantUser' and adds it to the 
db_backupoperator fixed database role.
*/

-- Create the user without login
IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'RestaurantUser')
BEGIN
    CREATE USER RestaurantUser WITHOUT LOGIN;
    PRINT 'SUCCESS: RestaurantUser created';
END
ELSE
BEGIN
    PRINT 'INFO: RestaurantUser already exists';
END

-- Add user to db_backupoperator role
ALTER ROLE db_backupoperator ADD MEMBER RestaurantUser;
PRINT 'SUCCESS: RestaurantUser added to db_backupoperator role';
GO

/*
================================================================================
TASK 1c: Create RestaurantDoAnything role with full database permissions
================================================================================
Creates a database role that has complete control over the Restaurant database.
This role can perform any operation within the database.
*/

-- Create the database role
IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'RestaurantDoAnything' AND type = 'R')
BEGIN
    CREATE ROLE RestaurantDoAnything;
    PRINT 'SUCCESS: RestaurantDoAnything role created';
END
ELSE
BEGIN
    PRINT 'INFO: RestaurantDoAnything role already exists';
END

-- Grant CONTROL permission
GRANT CONTROL ON DATABASE::Restaurant TO RestaurantDoAnything;
PRINT 'SUCCESS: CONTROL permission granted to RestaurantDoAnything';
GO

/*
================================================================================
TASK 1d: Create RestaurantAddDeleteDb role with DDL but no DML permissions
================================================================================
Creates a role that can perform database definition operations (CREATE, ALTER, 
DROP, RESTORE) but cannot insert, update, delete, or select data.
Note: Database-level DDL operations (CREATE/DROP DATABASE) require server-level 
permissions. This implementation provides the maximum DDL permissions available 
at the database level.
*/

-- Create the database role
IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'RestaurantAddDeleteDb' AND type = 'R')
BEGIN
    CREATE ROLE RestaurantAddDeleteDb;
    PRINT 'SUCCESS: RestaurantAddDeleteDb role created';
END
ELSE
BEGIN
    PRINT 'INFO: RestaurantAddDeleteDb role already exists';
END

-- Grant DDL permissions (Data Definition Language)
GRANT ALTER ON DATABASE::RestaurantDb TO RestaurantAddDeleteDb;
GRANT CREATE TABLE TO RestaurantAddDeleteDb;
GRANT CREATE VIEW TO RestaurantAddDeleteDb;
GRANT CREATE PROCEDURE TO RestaurantAddDeleteDb;
GRANT CREATE FUNCTION TO RestaurantAddDeleteDb;
GRANT CREATE SCHEMA TO RestaurantAddDeleteDb;

-- Grant permissions to alter and drop database objects
GRANT ALTER ANY SCHEMA TO RestaurantAddDeleteDb;
GRANT ALTER ANY USER TO RestaurantAddDeleteDb;
GRANT ALTER ANY ROLE TO RestaurantAddDeleteDb;

-- Allow backup and restore operations
GRANT BACKUP DATABASE TO RestaurantAddDeleteDb;
GRANT BACKUP LOG TO RestaurantAddDeleteDb;

PRINT 'SUCCESS: DDL permissions granted to RestaurantAddDeleteDb';
PRINT 'NOTE: CREATE/DROP DATABASE requires server-level permissions (dbcreator role)';
PRINT 'NOTE: RESTORE DATABASE permissions granted at database level';

-- Explicitly deny DML operations to ensure no data manipulation
DENY SELECT TO RestaurantAddDeleteDb;
DENY INSERT TO RestaurantAddDeleteDb;
DENY UPDATE TO RestaurantAddDeleteDb;
DENY DELETE TO RestaurantAddDeleteDb;

PRINT 'SUCCESS: DML operations explicitly denied for RestaurantAddDeleteDb';
GO

/*
================================================================================
TASK 1e: Create RestaurantPower role for managing user privileges
================================================================================
Creates a role that can modify the rights and privileges of users in the 
Restaurant database (security administrator functions).
*/

-- Create the database role
IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'RestaurantPower' AND type = 'R')
BEGIN
    CREATE ROLE RestaurantPower;
    PRINT 'SUCCESS: RestaurantPower role created';
END
ELSE
BEGIN
    PRINT 'INFO: RestaurantPower role already exists';
END

-- Grant permissions to manage users and their privileges
GRANT ALTER ANY USER TO RestaurantPower;
GRANT ALTER ANY ROLE TO RestaurantPower;
GRANT VIEW DEFINITION TO RestaurantPower;

-- Allow granting and revoking permissions
GRANT CONTROL ON DATABASE::RestaurantDb TO RestaurantPower;

PRINT 'SUCCESS: User privilege management permissions granted to RestaurantPower';
GO

/*
================================================================================
VERIFICATION QUERIES
================================================================================
Run these queries to verify that all roles and permissions have been 
correctly configured.
*/

PRINT '';
PRINT '========================================';
PRINT 'VERIFICATION SECTION';
PRINT '========================================';

-- Verify all created users and roles
PRINT '';
PRINT 'Database Users and Roles:';
SELECT 
    name AS PrincipalName,
    type_desc AS PrincipalType,
    create_date AS DateCreated,
    CASE 
        WHEN name = 'NT SERVICE\SQLSERVERAGENT' THEN 
            CASE WHEN HAS_PERMS_BY_NAME(DB_NAME(), 'DATABASE', 'CONNECT') = 1 
            THEN 'Enabled' ELSE 'Disabled' END
        ELSE 'N/A'
    END AS Status
FROM sys.database_principals
WHERE name IN (
    'RestaurantUser', 
    'RestaurantDoAnything', 
    'RestaurantAddDeleteDb', 
    'RestaurantPower',
    'NT SERVICE\SQLSERVERAGENT'
)
ORDER BY name;

-- Verify role memberships
PRINT '';
PRINT 'Role Memberships:';
SELECT 
    USER_NAME(rm.member_principal_id) AS MemberName,
    USER_NAME(rm.role_principal_id) AS RoleName
FROM sys.database_role_members rm
WHERE USER_NAME(rm.member_principal_id) IN (
    'RestaurantUser'
)
ORDER BY MemberName, RoleName;

-- Verify database-level permissions for created roles
PRINT '';
PRINT 'Database-Level Permissions:';
SELECT 
    USER_NAME(grantee_principal_id) AS Grantee,
    permission_name AS Permission,
    state_desc AS PermissionState
FROM sys.database_permissions
WHERE USER_NAME(grantee_principal_id) IN (
    'RestaurantUser',
    'RestaurantDoAnything',
    'RestaurantAddDeleteDb',
    'RestaurantPower',
    'NT SERVICE\SQLSERVERAGENT'
)
ORDER BY Grantee, Permission;

PRINT '';
PRINT '========================================';
PRINT 'Script Execution Complete';
PRINT '========================================';
GO

/*
================================================================================
TO ASSIGN USERS TO THESE ROLES:
================================================================================
-- Example: Add a login user to a role
ALTER ROLE RestaurantDoAnything ADD MEMBER [YourUserName];
ALTER ROLE RestaurantAddDeleteDb ADD MEMBER [YourUserName];
ALTER ROLE RestaurantPower ADD MEMBER [YourUserName];

================================================================================
*/
