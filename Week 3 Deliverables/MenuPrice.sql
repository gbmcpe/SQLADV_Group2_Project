-- Create a function named fn_MenuPrice.
-- This function shows the menu item name and price from the Recipes table
CREATE FUNCTION dbo.fn_MenuPrice()
RETURNS TABLE
AS
RETURN
(
-- Select only unique rows so duplicates do not show more than once.
-- Rename the columns to make the results easy to read.
    SELECT DISTINCT
        Name AS MenuItem,
        Price AS MenuPrice
    FROM dbo.Recipes
);
GO

-- Run the function and show all results.
SELECT *
FROM dbo.fn_MenuPrice();
GO

