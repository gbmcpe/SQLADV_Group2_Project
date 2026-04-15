-- Shows each kitchen’s basic details and sorts by location_id.
SELECT
    location_id,
    name AS kitchen_name,
    address,
    num_stoves,
    created_at
FROM dbo.Locations
ORDER BY location_id;