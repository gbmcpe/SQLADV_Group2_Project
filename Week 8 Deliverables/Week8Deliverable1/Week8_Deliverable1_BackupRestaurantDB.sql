--Week 8 Deliverable 1: Backup RestaurantDB
BACKUP DATABASE RestaurantDB
TO DISK = 'C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\Backup\RestaurantDB_FullBackup.bak'
WITH INIT, NAME = 'RestaurantDB Full Backup', STATS = 10;

--Testing the backup
RESTORE VERIFYONLY
FROM DISK = 'C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\Backup\RestaurantDB_FullBackup.bak';