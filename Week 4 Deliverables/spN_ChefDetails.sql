USE RestaurantDB;
GO

/*========================================================
a. spN_ChefDetails
Shows chefs, their preferred suppliers, the recipes tied
to those chefs, and the recipe price.
Price is shown in Irish Pounds format.
========================================================*/
CREATE OR ALTER PROCEDURE dbo.spN_ChefDetails
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        c.ChefID,
        e.Name AS ChefName,
        c.ChefType,
        s.SupplierID,
        s.Name AS SupplierName,
        r.RecipeID,
        r.Name AS RecipeName,
        FORMAT(r.Price, 'C', 'en-IE') AS ItemPrice
    FROM Chefs c
    INNER JOIN Employees e
        ON c.ChefID = e.EmployeeID
    INNER JOIN ChefSuppliers cs
        ON c.ChefID = cs.ChefID
    INNER JOIN Suppliers s
        ON cs.SupplierID = s.SupplierID
    INNER JOIN ChefRecipes cr
        ON c.ChefID = cr.ChefID
    INNER JOIN Recipes r
        ON cr.RecipeID = r.RecipeID
    ORDER BY e.Name, s.Name, r.Name;
END;
GO


/*========================================================
b. spN_RecipeDetails
Shows each recipe, its ingredients, and the total amount
of ingredients used in that recipe.
Recipe price is shown in Irish Pounds format.
========================================================*/
CREATE OR ALTER PROCEDURE dbo.spN_RecipeDetails
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        r.RecipeID,
        r.Name AS RecipeName,
        i.IngredientID,
        i.Name AS IngredientName,
        i.Unit,
        ri.Quantity,
        SUM(ri.Quantity) OVER (PARTITION BY r.RecipeID) AS TotalIngredientAmount,
        FORMAT(r.Price, 'C', 'en-IE') AS TotalDue
    FROM Recipes r
    INNER JOIN RecipeIngredients ri
        ON r.RecipeID = ri.RecipeID
    INNER JOIN Ingredients i
        ON ri.IngredientID = i.IngredientID
    ORDER BY r.Name, i.Name;
END;
GO


/*========================================================
c. spN_RecipeIngredientDetails
Shows the ingredients used in each recipe and the listed
price for the dish that uses those ingredients.
Price is shown in Irish Pounds format.
========================================================*/
CREATE OR ALTER PROCEDURE dbo.spN_RecipeIngredientDetails
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        r.RecipeID,
        r.Name AS RecipeName,
        i.IngredientID,
        i.Name AS IngredientName,
        i.Unit,
        ri.Quantity,
        FORMAT(r.Price, 'C', 'en-IE') AS TotalDue
    FROM Recipes r
    INNER JOIN RecipeIngredients ri
        ON r.RecipeID = ri.RecipeID
    INNER JOIN Ingredients i
        ON ri.IngredientID = i.IngredientID
    ORDER BY r.Name, i.Name;
END;
GO


/*========================================================
d. spN_KitchenDetails
Shows kitchen details for all chefs or for one chef only.
Chef salary is shown in Irish Pounds format.
Leave @ChefID empty to show all chefs.
========================================================*/
CREATE OR ALTER PROCEDURE dbo.spN_KitchenDetails
    @ChefID INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        c.ChefID,
        e.Name AS ChefName,
        c.ChefType,
        l.LocationID,
        l.Name AS LocationName,
        l.Address,
        l.NumStoves,
        FORMAT(c.Salary, 'C', 'en-IE') AS TotalDue
    FROM Chefs c
    INNER JOIN Employees e
        ON c.ChefID = e.EmployeeID
    INNER JOIN ChefLocations cl
        ON c.ChefID = cl.ChefID
    INNER JOIN Locations l
        ON cl.LocationID = l.LocationID
    WHERE @ChefID IS NULL OR c.ChefID = @ChefID
    ORDER BY e.Name, l.Name;
END;
GO


/*========================================================
e. spN_CustomerDetails
Shows customer details for all customers or one customer only.
Also shows favorite recipe and favorite server when available.
Leave @CustomerID empty to show all customers.
========================================================*/
CREATE OR ALTER PROCEDURE dbo.spN_CustomerDetails
    @CustomerID INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        c.CustomerID,
        c.Name AS CustomerName,
        c.AgeRange,
        c.FavoriteRecipeID,
        r.Name AS FavoriteRecipeName,
        c.FavoriteServerID,
        es.Name AS FavoriteServerName,
        c.CreatedAt
    FROM Customers c
    LEFT JOIN Recipes r
        ON c.FavoriteRecipeID = r.RecipeID
    LEFT JOIN Servers s
        ON c.FavoriteServerID = s.ServerID
    LEFT JOIN Employees es
        ON s.ServerID = es.EmployeeID
    WHERE @CustomerID IS NULL OR c.CustomerID = @CustomerID
    ORDER BY c.CustomerID;
END;
GO


/*========================
Test Calls
========================*/
EXEC dbo.spN_ChefDetails;
EXEC dbo.spN_RecipeDetails;
EXEC dbo.spN_RecipeIngredientDetails;
EXEC dbo.spN_KitchenDetails;
EXEC dbo.spN_KitchenDetails @ChefID = 1;
EXEC dbo.spN_CustomerDetails;
EXEC dbo.spN_CustomerDetails @CustomerID = 1;
GO
