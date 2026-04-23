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
        c.chef_id,
        e.name AS chef_name,
        c.chef_type,
        s.supplier_id,
        s.name AS supplier_name,
        r.recipe_id,
        r.name AS recipe_name,
        FORMAT(r.price, 'C', 'en-IE') AS item_price
    FROM dbo.Chefs AS c
    INNER JOIN dbo.Employees AS e
        ON c.chef_id = e.employee_id
    INNER JOIN dbo.Chef_Suppliers AS cs
        ON c.chef_id = cs.chef_id
    INNER JOIN dbo.Suppliers AS s
        ON cs.supplier_id = s.supplier_id
    INNER JOIN dbo.Chef_Recipes AS cr
        ON c.chef_id = cr.chef_id
    INNER JOIN dbo.Recipes AS r
        ON cr.recipe_id = r.recipe_id
    ORDER BY
        e.name,
        s.name,
        r.name;
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
        r.recipe_id,
        r.name AS recipe_name,
        i.ingredient_id,
        i.name AS ingredient_name,
        i.unit,
        ri.quantity,
        SUM(ri.quantity) OVER (PARTITION BY r.recipe_id) AS total_ingredient_amount,
        FORMAT(r.price, 'C', 'en-IE') AS totaldue
    FROM dbo.Recipes AS r
    INNER JOIN dbo.Recipe_Ingredients AS ri
        ON r.recipe_id = ri.recipe_id
    INNER JOIN dbo.Ingredients AS i
        ON ri.ingredient_id = i.ingredient_id
    ORDER BY
        r.name,
        i.name;
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
        r.recipe_id,
        r.name AS recipe_name,
        i.ingredient_id,
        i.name AS ingredient_name,
        i.unit,
        ri.quantity,
        FORMAT(r.price, 'C', 'en-IE') AS totaldue
    FROM dbo.Recipes AS r
    INNER JOIN dbo.Recipe_Ingredients AS ri
        ON r.recipe_id = ri.recipe_id
    INNER JOIN dbo.Ingredients AS i
        ON ri.ingredient_id = i.ingredient_id
    ORDER BY
        r.name,
        i.name;
END;
GO


/*========================================================
d. spN_KitchenDetails
Shows kitchen details for all chefs or for one chef only.
Chef salary is shown in Irish Pounds format.
Leave @chef_id empty to show all chefs.
========================================================*/
CREATE OR ALTER PROCEDURE dbo.spN_KitchenDetails
    @chef_id INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        c.chef_id,
        e.name AS chef_name,
        c.chef_type,
        l.location_id,
        l.name AS location_name,
        l.address,
        l.num_stoves,
        FORMAT(c.salary, 'C', 'en-IE') AS totaldue
    FROM dbo.Chefs AS c
    INNER JOIN dbo.Employees AS e
        ON c.chef_id = e.employee_id
    INNER JOIN dbo.Chef_Locations AS cl
        ON c.chef_id = cl.chef_id
    INNER JOIN dbo.Locations AS l
        ON cl.location_id = l.location_id
    WHERE @chef_id IS NULL
       OR c.chef_id = @chef_id
    ORDER BY
        e.name,
        l.name;
END;
GO


/*========================================================
e. spN_CustomerDetails
Shows customer details for all customers or one customer only.
Also shows favorite recipe and favorite server when available.
Leave @customer_id empty to show all customers.
========================================================*/
CREATE OR ALTER PROCEDURE dbo.spN_CustomerDetails
    @customer_id INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        c.customer_id,
        c.name AS customer_name,
        c.age_range,
        c.favorite_recipe_id,
        r.name AS favorite_recipe_name,
        c.favorite_server_id,
        es.name AS favorite_server_name,
        c.created_at
    FROM dbo.Customers AS c
    LEFT JOIN dbo.Recipes AS r
        ON c.favorite_recipe_id = r.recipe_id
    LEFT JOIN dbo.Servers AS s
        ON c.favorite_server_id = s.server_id
    LEFT JOIN dbo.Employees AS es
        ON s.server_id = es.employee_id
    WHERE @customer_id IS NULL
       OR c.customer_id = @customer_id
    ORDER BY
        c.customer_id;
END;
GO

/*========================
Test Calls
========================*/
EXEC dbo.spN_ChefDetails;
EXEC dbo.spN_RecipeDetails;
EXEC dbo.spN_RecipeIngredientDetails;
EXEC dbo.spN_KitchenDetails;
EXEC dbo.spN_KitchenDetails @chef_id = 1;
EXEC dbo.spN_CustomerDetails;
EXEC dbo.spN_CustomerDetails @customer_id = 1;