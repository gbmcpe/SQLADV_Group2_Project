--Drop the function if it already exists
IF OBJECT_ID('dbo.fn_OrderDistribution', 'IF') IS NOT NULL
    DROP FUNCTION dbo.fn_OrderDistribution;
GO

--Recreate the function
CREATE FUNCTION dbo.fn_OrderDistribution()
RETURNS TABLE
AS
RETURN
(
    SELECT 
        order_method AS OrderMethod,
        COUNT(*) AS OrderCount
    FROM dbo.Orders
    GROUP BY order_method

    UNION ALL

    SELECT 
        'All' AS OrderMethod,
        COUNT(*) AS OrderCount
    FROM dbo.Orders
);
GO

--Test the function
SELECT *
FROM dbo.fn_OrderDistribution();
GO