-- Step 1: Drop child tables if they exist
DROP TABLE IF EXISTS dbo.Server_Tables;
DROP TABLE IF EXISTS dbo.Location_Charities;
DROP TABLE IF EXISTS dbo.Reservations;
DROP TABLE IF EXISTS dbo.Order_Items;
DROP TABLE IF EXISTS dbo.Orders;
DROP TABLE IF EXISTS dbo.Customers;
DROP TABLE IF EXISTS dbo.Chef_Recipes;
DROP TABLE IF EXISTS dbo.Recipe_Ingredients;
DROP TABLE IF EXISTS dbo.Recipes;
DROP TABLE IF EXISTS dbo.Ingredients;
DROP TABLE IF EXISTS dbo.Chef_Suppliers;
DROP TABLE IF EXISTS dbo.Suppliers;
DROP TABLE IF EXISTS dbo.Servers;
DROP TABLE IF EXISTS dbo.Chef_Locations;
DROP TABLE IF EXISTS dbo.Chefs;
DROP TABLE IF EXISTS dbo.Employees;
DROP TABLE IF EXISTS dbo.Locations;
DROP TABLE IF EXISTS dbo.Charities;

--Step 2: Create table section
------------------------------------------------------------
-- LOCATIONS
------------------------------------------------------------
CREATE TABLE dbo.Locations (
    location_id INT IDENTITY(1,1) PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    address VARCHAR(255),
    num_stoves INT NOT NULL CHECK (num_stoves >= 0),
    created_at DATETIME DEFAULT GETDATE()
);

------------------------------------------------------------
-- EMPLOYEES
------------------------------------------------------------
CREATE TABLE dbo.Employees (
    employee_id INT IDENTITY(1,1) PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    hire_date DATE,
    phone VARCHAR(20),
    email VARCHAR(100),
    location_id INT,
    FOREIGN KEY (location_id) REFERENCES dbo.Locations(location_id)
);

------------------------------------------------------------
-- CHEFS
------------------------------------------------------------
CREATE TABLE dbo.Chefs (
    chef_id INT PRIMARY KEY,
    chef_type VARCHAR(50) NOT NULL,
    salary DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (chef_id) REFERENCES dbo.Employees(employee_id)
);

------------------------------------------------------------
-- CHEF_LOCATIONS (many-to-many)
------------------------------------------------------------
CREATE TABLE dbo.Chef_Locations (
    chef_id INT,
    location_id INT,
    PRIMARY KEY (chef_id, location_id),
    FOREIGN KEY (chef_id) REFERENCES dbo.Chefs(chef_id),
    FOREIGN KEY (location_id) REFERENCES dbo.Locations(location_id)
);

------------------------------------------------------------
-- SERVERS
------------------------------------------------------------
CREATE TABLE dbo.Servers (
    server_id INT PRIMARY KEY,
    num_tables INT DEFAULT 0,
    salary DECIMAL(10,2),
    FOREIGN KEY (server_id) REFERENCES dbo.Employees(employee_id)
);

------------------------------------------------------------
-- SUPPLIERS
------------------------------------------------------------
CREATE TABLE dbo.Suppliers (
    supplier_id INT IDENTITY(1,1) PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    contact_info VARCHAR(255)
);

------------------------------------------------------------
-- CHEF_SUPPLIERS (many-to-many)
------------------------------------------------------------
CREATE TABLE dbo.Chef_Suppliers (
    chef_id INT,
    supplier_id INT,
    PRIMARY KEY (chef_id, supplier_id),
    FOREIGN KEY (chef_id) REFERENCES dbo.Chefs(chef_id),
    FOREIGN KEY (supplier_id) REFERENCES dbo.Suppliers(supplier_id)
);

------------------------------------------------------------
-- INGREDIENTS
------------------------------------------------------------
CREATE TABLE dbo.Ingredients (
    ingredient_id INT IDENTITY(1,1) PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    unit VARCHAR(50)
);

------------------------------------------------------------
-- RECIPES
------------------------------------------------------------
CREATE TABLE dbo.Recipes (
    recipe_id INT IDENTITY(1,1) PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    price DECIMAL(8,2) NOT NULL,
    is_orderable BIT DEFAULT 1,
    created_at DATETIME DEFAULT GETDATE()
);

------------------------------------------------------------
-- RECIPE_INGREDIENTS (many-to-many)
------------------------------------------------------------
CREATE TABLE dbo.Recipe_Ingredients (
    recipe_id INT,
    ingredient_id INT,
    quantity DECIMAL(10,2) NOT NULL,
    PRIMARY KEY (recipe_id, ingredient_id),
    FOREIGN KEY (recipe_id) REFERENCES dbo.Recipes(recipe_id),
    FOREIGN KEY (ingredient_id) REFERENCES dbo.Ingredients(ingredient_id)
);

------------------------------------------------------------
-- CHEF_RECIPES (many-to-many)
------------------------------------------------------------
CREATE TABLE dbo.Chef_Recipes (
    chef_id INT,
    recipe_id INT,
    PRIMARY KEY (chef_id, recipe_id),
    FOREIGN KEY (chef_id) REFERENCES dbo.Chefs(chef_id),
    FOREIGN KEY (recipe_id) REFERENCES dbo.Recipes(recipe_id)
);

------------------------------------------------------------
-- CUSTOMERS
------------------------------------------------------------
CREATE TABLE dbo.Customers (
    customer_id INT IDENTITY(1,1) PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    age_range VARCHAR(50),
    favorite_recipe_id INT,
    favorite_server_id INT,
    created_at DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (favorite_recipe_id) REFERENCES dbo.Recipes(recipe_id),
    FOREIGN KEY (favorite_server_id) REFERENCES dbo.Servers(server_id)
);

------------------------------------------------------------
-- ORDERS
------------------------------------------------------------
CREATE TABLE dbo.Orders (
    order_id INT IDENTITY(1,1) PRIMARY KEY,
    billing_number VARCHAR(50) UNIQUE NOT NULL,
    customer_id INT,
    server_id INT,
    location_id INT,
    order_time DATETIME DEFAULT GETDATE(),
    total_amount DECIMAL(10,2),
    FOREIGN KEY (customer_id) REFERENCES dbo.Customers(customer_id),
    FOREIGN KEY (server_id) REFERENCES dbo.Servers(server_id),
    FOREIGN KEY (location_id) REFERENCES dbo.Locations(location_id)
);

------------------------------------------------------------
-- ORDER_ITEMS
------------------------------------------------------------
CREATE TABLE dbo.Order_Items (
    order_id INT,
    recipe_id INT,
    quantity INT NOT NULL CHECK (quantity > 0),
    price_at_time DECIMAL(8,2),
    PRIMARY KEY (order_id, recipe_id),
    FOREIGN KEY (order_id) REFERENCES dbo.Orders(order_id),
    FOREIGN KEY (recipe_id) REFERENCES dbo.Recipes(recipe_id)
);

------------------------------------------------------------
-- RESERVATIONS
------------------------------------------------------------
CREATE TABLE dbo.Reservations (
    reservation_id INT IDENTITY(1,1) PRIMARY KEY,
    customer_id INT,
    location_id INT NOT NULL,
    reservation_time DATETIME NOT NULL,
    table_number INT,
    is_recurring BIT DEFAULT 0,
    recurrence_pattern VARCHAR(100),
    created_at DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (customer_id) REFERENCES dbo.Customers(customer_id),
    FOREIGN KEY (location_id) REFERENCES dbo.Locations(location_id)
);

------------------------------------------------------------
-- CHARITIES
------------------------------------------------------------
CREATE TABLE dbo.Charities (
    charity_id INT IDENTITY(1,1) PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description VARCHAR(255)
);

------------------------------------------------------------
-- LOCATION_CHARITIES (many-to-many)
------------------------------------------------------------
CREATE TABLE dbo.Location_Charities (
    location_id INT,
    charity_id INT,
    PRIMARY KEY (location_id, charity_id),
    FOREIGN KEY (location_id) REFERENCES dbo.Locations(location_id),
    FOREIGN KEY (charity_id) REFERENCES dbo.Charities(charity_id)
);

------------------------------------------------------------
-- SERVER_TABLES (added for requirement)
------------------------------------------------------------
CREATE TABLE dbo.Server_Tables (
    server_id INT,
    table_number INT,
    PRIMARY KEY (server_id, table_number),
    FOREIGN KEY (server_id) REFERENCES dbo.Servers(server_id)
);

--Step 3: Insert section
------------------------------------------------------------
-- 1. LOCATIONS (100 rows)
------------------------------------------------------------
;WITH Numbers AS (
    SELECT TOP (100)
        ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS n
    FROM sys.objects
)
INSERT INTO dbo.Locations (name, address, num_stoves, created_at)
SELECT
    'Location ' + CAST(n AS VARCHAR(10)) AS name,
    'Address ' + CAST(n AS VARCHAR(10)) AS address,
    (n % 10) + 1 AS num_stoves,
    DATEADD(MINUTE, n, GETDATE()) AS created_at
FROM Numbers;

------------------------------------------------------------
-- 2. EMPLOYEES (100 rows)
------------------------------------------------------------
;WITH Numbers AS (
    SELECT TOP (100)
        ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS n
    FROM sys.objects
)
INSERT INTO dbo.Employees (name, hire_date, phone, email, location_id)
SELECT
    'Employee ' + CAST(n AS VARCHAR(10)) AS name,
    DATEADD(DAY, n, '2020-01-01') AS hire_date,
    '555-010' + CAST(n % 10 AS VARCHAR(10)) AS phone,
    'employee' + CAST(n AS VARCHAR(10)) + '@restaurant.com' AS email,
    ((n - 1) % 100) + 1 AS location_id
FROM Numbers;

------------------------------------------------------------
-- 3. CHEFS (60 rows, subset of Employees 1–60)
------------------------------------------------------------
;WITH Numbers AS (
    SELECT TOP (60)
        ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS n
    FROM sys.objects
)
INSERT INTO dbo.Chefs (chef_id, chef_type, salary)
SELECT
    n AS chef_id,
    CASE
        WHEN n % 4 = 0 THEN 'Head Chef'
        WHEN n % 4 = 1 THEN 'Sous Chef'
        WHEN n % 4 = 2 THEN 'Pastry Chef'
        ELSE 'Line Cook'
    END AS chef_type,
    50000 + (n * 150) AS salary
FROM Numbers;

------------------------------------------------------------
-- 4. CHEF_LOCATIONS (120 rows, many-to-many)
------------------------------------------------------------
;WITH Numbers AS (
    SELECT TOP (120)
        ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS n
    FROM sys.objects
)
INSERT INTO dbo.Chef_Locations (chef_id, location_id)
SELECT
    ((n - 1) % 60) + 1 AS chef_id,
    ((n - 1) % 100) + 1 AS location_id
FROM Numbers;

------------------------------------------------------------
-- 5. SERVERS (40 rows, Employees 41–80)
------------------------------------------------------------
;WITH Numbers AS (
    SELECT TOP (40)
        ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS n
    FROM sys.objects
)
INSERT INTO dbo.Servers (server_id, num_tables, salary)
SELECT
    n + 40 AS server_id,              -- maps to Employees 41–80
    (n % 8) + 1 AS num_tables,
    30000 + ((n + 40) * 100) AS salary
FROM Numbers;

------------------------------------------------------------
-- 6. SUPPLIERS (100 rows)
------------------------------------------------------------
;WITH Numbers AS (
    SELECT TOP (100)
        ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS n
    FROM sys.objects
)
INSERT INTO dbo.Suppliers (name, contact_info)
SELECT
    'Supplier ' + CAST(n AS VARCHAR(10)) AS name,
    'Contact info for Supplier ' + CAST(n AS VARCHAR(10)) AS contact_info
FROM Numbers;

------------------------------------------------------------
-- 7. CHEF_SUPPLIERS (200 rows, many-to-many)
------------------------------------------------------------
;WITH Numbers AS (
    SELECT TOP (200)
        ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS n
    FROM sys.objects
)
INSERT INTO dbo.Chef_Suppliers (chef_id, supplier_id)
SELECT
    ((n - 1) % 60) + 1 AS chef_id,
    ((n - 1) % 100) + 1 AS supplier_id
FROM Numbers;

------------------------------------------------------------
-- 8. INGREDIENTS (100 rows)
------------------------------------------------------------
;WITH Numbers AS (
    SELECT TOP (100)
        ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS n
    FROM sys.objects
)
INSERT INTO dbo.Ingredients (name, unit)
SELECT
    'Ingredient ' + CAST(n AS VARCHAR(10)) AS name,
    CASE
        WHEN n % 3 = 0 THEN 'grams'
        WHEN n % 3 = 1 THEN 'liters'
        ELSE 'pieces'
    END AS unit
FROM Numbers;

------------------------------------------------------------
-- 9. RECIPES (100 rows)
------------------------------------------------------------
;WITH Numbers AS (
    SELECT TOP (100)
        ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS n
    FROM sys.objects
)
INSERT INTO dbo.Recipes (name, price, is_orderable, created_at)
SELECT
    'Recipe ' + CAST(n AS VARCHAR(10)) AS name,
    CAST(10 + (n % 20) AS DECIMAL(8,2)) AS price,
    CASE WHEN n % 5 = 0 THEN 0 ELSE 1 END AS is_orderable,
    DATEADD(SECOND, n, GETDATE()) AS created_at
FROM Numbers;

------------------------------------------------------------
-- 10. RECIPE_INGREDIENTS (300 rows, many-to-many)
------------------------------------------------------------
;WITH Numbers AS (
    SELECT TOP (300)
        ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS n
    FROM sys.objects
)
INSERT INTO dbo.Recipe_Ingredients (recipe_id, ingredient_id, quantity)
SELECT
    ((n - 1) % 100) + 1 AS recipe_id,
    ((n - 1) % 100) + 1 AS ingredient_id,
    CAST((n % 10) + 1 AS DECIMAL(10,2)) AS quantity
FROM Numbers;

------------------------------------------------------------
-- 11. CHEF_RECIPES (200 rows, many-to-many)
------------------------------------------------------------
;WITH Numbers AS (
    SELECT TOP (200)
        ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS n
    FROM sys.objects
)
INSERT INTO dbo.Chef_Recipes (chef_id, recipe_id)
SELECT
    ((n - 1) % 60) + 1 AS chef_id,
    ((n - 1) % 100) + 1 AS recipe_id
FROM Numbers;

------------------------------------------------------------
-- 12. CUSTOMERS (100 rows)
------------------------------------------------------------
;WITH Numbers AS (
    SELECT TOP (100)
        ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS n
    FROM sys.objects
)
INSERT INTO dbo.Customers (name, age_range, favorite_recipe_id, favorite_server_id, created_at)
SELECT
    'Customer ' + CAST(n AS VARCHAR(10)) AS name,
    CASE 
        WHEN n % 4 = 0 THEN '18-25'
        WHEN n % 4 = 1 THEN '26-35'
        WHEN n % 4 = 2 THEN '36-50'
        ELSE '51+'
    END AS age_range,
    ((n - 1) % 100) + 1 AS favorite_recipe_id,
    ((n - 1) % 40) + 41 AS favorite_server_id,  -- servers 41–80
    DATEADD(MINUTE, n, GETDATE()) AS created_at
FROM Numbers;

------------------------------------------------------------
-- 13. ORDERS (100 rows)
------------------------------------------------------------
;WITH Numbers AS (
    SELECT TOP (100)
        ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS n
    FROM sys.objects
)
INSERT INTO dbo.Orders (billing_number, customer_id, server_id, location_id, order_time, total_amount)
SELECT
    'BILL-' + RIGHT('00000' + CAST(n AS VARCHAR(5)), 5) AS billing_number,
    ((n - 1) % 100) + 1 AS customer_id,
    ((n - 1) % 40) + 41 AS server_id,   -- servers 41–80
    ((n - 1) % 100) + 1 AS location_id,
    DATEADD(SECOND, n, GETDATE()) AS order_time,
    CAST(20 + (n % 50) AS DECIMAL(10,2)) AS total_amount
FROM Numbers;

------------------------------------------------------------
-- 14. ORDER_ITEMS (300 rows)
------------------------------------------------------------
;WITH Numbers AS (
    SELECT TOP (300)
        ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS n
    FROM sys.objects
)
INSERT INTO dbo.Order_Items (order_id, recipe_id, quantity, price_at_time)
SELECT
    ((n - 1) % 100) + 1 AS order_id,
    ((n - 1) % 100) + 1 AS recipe_id,
    (n % 5) + 1 AS quantity,
    CAST(10 + (n % 20) AS DECIMAL(8,2)) AS price_at_time
FROM Numbers;

------------------------------------------------------------
-- 15. RESERVATIONS (100 rows)
-- Satisfies: many customers with different table_number values
------------------------------------------------------------
;WITH Numbers AS (
    SELECT TOP (100)
        ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS n
    FROM sys.objects
)
INSERT INTO dbo.Reservations (customer_id, location_id, reservation_time, table_number, is_recurring, recurrence_pattern, created_at)
SELECT
    ((n - 1) % 100) + 1 AS customer_id,
    ((n - 1) % 100) + 1 AS location_id,
    DATEADD(HOUR, n, GETDATE()) AS reservation_time,
    (n % 30) + 1 AS table_number,              -- table numbers 1–31
    CASE WHEN n % 10 = 0 THEN 1 ELSE 0 END AS is_recurring,
    CASE WHEN n % 10 = 0 THEN 'WEEKLY' ELSE NULL END AS recurrence_pattern,
    DATEADD(HOUR, n, GETDATE()) AS created_at
FROM Numbers;

------------------------------------------------------------
-- 16. CHARITIES (100 rows)
------------------------------------------------------------
;WITH Numbers AS (
    SELECT TOP (100)
        ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS n
    FROM sys.objects
)
INSERT INTO dbo.Charities (name, description)
SELECT
    'Charity ' + CAST(n AS VARCHAR(10)) AS name,
    'Description for Charity ' + CAST(n AS VARCHAR(10)) AS description
FROM Numbers;

------------------------------------------------------------
-- 17. LOCATION_CHARITIES (200 rows, many-to-many)
------------------------------------------------------------
;WITH Numbers AS (
    SELECT TOP (200)
        ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS n
    FROM sys.objects
)
INSERT INTO dbo.Location_Charities (location_id, charity_id)
SELECT
    ((n - 1) % 100) + 1 AS location_id,
    ((n - 1) % 100) + 1 AS charity_id
FROM Numbers;

------------------------------------------------------------
-- 18. SERVER_TABLES (server -> table assignments)
-- Satisfies: at least 5 servers have more than one table
------------------------------------------------------------

-- Base: every server (41–80) gets one table
;WITH Numbers AS (
    SELECT TOP (40)
        ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS n
    FROM sys.objects
)
INSERT INTO dbo.Server_Tables (server_id, table_number)
SELECT
    n + 40 AS server_id,          -- servers 41–80
    (n % 30) + 1 AS table_number
FROM Numbers;

-- Extra: servers 41–45 get 3 additional tables each
;WITH Extra AS (
    SELECT s.server_id, t.table_number
    FROM (VALUES (41),(42),(43),(44),(45)) AS s(server_id)
    CROSS JOIN (VALUES (31),(32),(33)) AS t(table_number)
)
INSERT INTO dbo.Server_Tables (server_id, table_number)
SELECT server_id, table_number
FROM Extra;

------------------------------------------------------------
-- AI PROMPTS USED
------------------------------------------------------------
--Prompt 1: Fed the AI both the code from part 1 and the screenshot from part 2 to then make the inserts.
--Prompt 2: I was getting errors and the AI showed me that I needed to drop child tables if they exist (step 1).
--Prompt 3: I made an additonal prompt to tell the AI to match the schema because that was the other reason I had errors.
--Prompt 4: AI then showed me that it could do CTE-generated inserts to be more effiecient and less lines of code so I said yes and then the inserts were generated.