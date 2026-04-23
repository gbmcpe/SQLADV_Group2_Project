-- Returns all charities or a single charity by ID.
DROP PROCEDURE IF EXISTS spN_GetCharities;
GO

CREATE PROCEDURE spN_GetCharities
    @CharityID INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF @CharityID IS NULL
    BEGIN
        SELECT charity_id, name, description
        FROM Charities;
    END
    ELSE
    BEGIN
        SELECT charity_id, name, description
        FROM Charities
        WHERE charity_id = @CharityID;
    END
END;
GO



-- Inserts a new charity record.
DROP PROCEDURE IF EXISTS spN_InsertCharities;
GO

CREATE PROCEDURE spN_InsertCharities
    @Name VARCHAR(100),
    @Description VARCHAR(255) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO Charities (name, description)
    VALUES (@Name, @Description);

    SELECT SCOPE_IDENTITY() AS NewCharityID;
END;
GO



-- Updates an existing charity record.
DROP PROCEDURE IF EXISTS spN_UpdateCharities;
GO

CREATE PROCEDURE spN_UpdateCharities
    @CharityID INT,
    @Name VARCHAR(100),
    @Description VARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE Charities
    SET name = @Name,
        description = @Description
    WHERE charity_id = @CharityID;

    SELECT charity_id, name, description
    FROM Charities
    WHERE charity_id = @CharityID;
END;
GO



-- Deletes a charity record by ID.
DROP PROCEDURE IF EXISTS spN_DeleteCharities;
GO

CREATE PROCEDURE spN_DeleteCharities
    @CharityID INT
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM Charities
    WHERE charity_id = @CharityID;

    SELECT charity_id, name, description
    FROM Charities;
END;
GO


-- SELECT all charities
EXEC spN_GetCharities;
-- SELECT one charity by ID
EXEC spN_GetCharities @CharityID = 1;
GO

-- INSERT a charity
EXEC spN_InsertCharities
    @Name = 'New Charity',
    @Description = 'A new charity organization';
GO

-- UPDATE a charity
EXEC spN_UpdateCharities
    @CharityID = 1,
    @Name = 'Updated Charity Name',
    @Description = 'Updated charity description';
GO

-- DELETE a charity
EXEC spN_DeleteCharities
    @CharityID = 1;
GO