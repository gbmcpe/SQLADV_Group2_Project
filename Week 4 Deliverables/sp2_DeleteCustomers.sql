/* 
   Purpose: Delete a customer record by ID.
   Notes: Returns the remaining customers so the procedure always returns data.
*/

--Incase procedure already exists drop it
DROP PROCEDURE IF EXISTS sp2_DeleteCustomers;
GO

CREATE PROCEDURE sp2_DeleteCustomers
    @CustomerID INT
AS
BEGIN
    SET NOCOUNT ON;

    --Delete the customer
    DELETE FROM Customers
    WHERE customer_id = @CustomerID;

    --Return remaining customers
    SELECT customer_id, name, age_range, favorite_recipe_id,
           favorite_server_id, created_at
    FROM Customers;
END;
GO