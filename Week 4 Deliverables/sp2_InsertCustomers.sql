/* 
   Purpose: Insert a new customer record.
   Notes: Automatically sets created_at using GETDATE().
*/

--Incase procedure already exists drop it
DROP PROCEDURE IF EXISTS sp2_InsertCustomers;
GO

CREATE PROCEDURE sp2_InsertCustomers
    @Name VARCHAR(100),
    @AgeRange VARCHAR(50),
    @FavoriteRecipeID INT = NULL,
    @FavoriteServerID INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    --Insert new customer into table
    INSERT INTO Customers(name, age_range, favorite_recipe_id, favorite_server_id, created_at)
    VALUES(@Name, @AgeRange, @FavoriteRecipeID, @FavoriteServerID, GETDATE());

    --Return the new identity value
    SELECT SCOPE_IDENTITY() AS NewCustomerID;
END;
GO