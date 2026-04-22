/* 
   Purpose: Update an existing customer record.
   Notes: Updates at least 3 fields as required.
*/

--Incase procedure already exists drop it
DROP PROCEDURE IF EXISTS sp2_UpdateCustomers;
GO

CREATE PROCEDURE sp2_UpdateCustomers
    @CustomerID INT,
    @Name VARCHAR(100),
    @AgeRange VARCHAR(50),
    @FavoriteRecipeID INT,
    @FavoriteServerID INT
AS
BEGIN
    SET NOCOUNT ON;

    --Update customer fields
    UPDATE Customers
    SET name = @Name,
        age_range = @AgeRange,
        favorite_recipe_id = @FavoriteRecipeID,
        favorite_server_id = @FavoriteServerID
    WHERE customer_id = @CustomerID;

    --Return updated record
    SELECT customer_id, name, age_range, favorite_recipe_id,
           favorite_server_id, created_at
    FROM Customers
    WHERE customer_id = @CustomerID;
END;
GO