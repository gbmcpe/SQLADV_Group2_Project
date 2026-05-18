
--Week 8 Deliverable 1: Backup RestaurantDB
BACKUP DATABASE RestaurantDB
TO DISK = 'C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\Backup\RestaurantDB_FullBackup.bak'
WITH INIT, NAME = 'RestaurantDB Full Backup', STATS = 10;

--Testing the backup
RESTORE VERIFYONLY
FROM DISK = 'C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\Backup\RestaurantDB_FullBackup.bak';

--Deliverable 2

ALTER DATABASE RestaurantDB2
ADD LOG FILE(
NAME= 'Restaurant_Transaction_Log',
FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\DATA\Restaurant_Transaction_Log.ldf',
SIZE = 50MB,
MAXSIZE =500MB,
FILEGROWTH = 10%
)

--Deliverable 3

DBCC SHRINKFILE (Restaurant_Transaction_Log, 1)
