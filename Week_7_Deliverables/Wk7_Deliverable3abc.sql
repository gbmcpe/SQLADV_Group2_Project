


-- Need to enable guest permissions.
-- From my research, I think Order_table_User will automatically inherit guest access level.

GRANT CONNECT TO guest

CREATE LOGIN Dishes_table_User WITH PASSWORD = 'DummyP@55'
CREATE LOGIN Order_table_User WITH PASSWORD = 'DummyP@55'
CREATE LOGIN Server_table_User WITH PASSWORD = 'DummyP@55'

CREATE USER Dishes_table_User FOR LOGIN Dishes_table_User
CREATE USER Order_table_User FOR LOGIN Order_table_User
CREATE USER Server_table_User FOR LOGIN Server_table_User

ALTER ROLE db_datareader ADD MEMBER Dishes_table_User
ALTER ROLE db_datawriter ADD MEMBER Server_table_User





DROP LOGIN Dishes_table_User
DROP LOGIN Order_table_User 
DROP LOGIN Server_table_User

DROP USER Dishes_table_User 
DROP USER Order_table_User 
DROP USER Server_table_User 