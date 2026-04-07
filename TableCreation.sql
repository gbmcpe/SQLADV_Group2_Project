CREATE TABLE Restaurant
(
RestID int  IDENTITY(1,1) PRIMARY KEY,
RestName varchar(50),
RestAddress varchar(50)  NOT NULL,
RestZip int  NOT NULL,


)