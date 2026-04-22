/* 
   Purpose: Return all customers or a single customer by ID.
   Notes: Includes optional parameter for filtering.
*/

--Incase procedure already exists drop it
DROP PROCEDURE IF EXISTS sp2_GetCustomers;
GO

CREATE PROCEDURE sp2_GetCustomers
    @CustomerID INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    --If no ID is passed return all customers
    IF @CustomerID IS NULL
    BEGIN
        SELECT customer_id, name, age_range, favorite_recipe_id,
               favorite_server_id, created_at
        FROM Customers;
    END
    ELSE
    BEGIN
        -- Return a single customer based on ID
        SELECT customer_id, name, age_range, favorite_recipe_id,
               favorite_server_id, created_at
        FROM Customers
        WHERE customer_id = @CustomerID;
    END
END;
GO