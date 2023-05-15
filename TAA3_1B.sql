---1B: The municipality is in the process of creating a vector dataset of all parking 
---spots in the city centre. For this they created the shapefile Parking_spots_Alkmaar.shp. 
---In order to see whether these correspond with the datasets from the Cadastre 
---and Ecorys they want you to compare them by listing the number of parking spots in 
---the neighbourhood for which “Parking_spots_Alkmaar” has been created. 
--(Note that you only need to make this comparison with the neighbourhoods with 
--BU_code: BU03610104, BU03610108, BU03610300, BU03610800, BU03610801, BU03610802 and BU03610803).

SELECT buurt_201622.bu_code, buurt_201622.bu_naam, COUNT(parking_lots_points2.Id) AS num_parking_spots
FROM buurt_201622
LEFT JOIN parking_lots_points2 ON ST_Contains(buurt_201622.geom, parking_lots_points2.geom)
WHERE buurt_201622.bu_code IN ('BU03610104', 'BU03610108', 'BU03610300', 'BU03610800', 'BU03610801', 'BU03610802', 'BU03610803')
GROUP BY buurt_201622.bu_code, buurt_201622.bu_naam;

------
SELECT bu_code, COUNT(*) AS total_parking_spots_ecorys_count
FROM parking_lots_points2_neighborhood
WHERE bu_code IN ('BU03610104', 'BU03610108', 'BU03610300', 'BU03610800', 'BU03610801', 'BU03610802', 'BU03610803')
GROUP BY bu_code

---when section id is included
SELECT bu_code, section_id, 
    SUM(capacity_street + capacity_parking_lots + capacity_private_driveways) AS total_capacity
FROM parking_lots_points2_neighborhood, section
WHERE bu_code IN ('BU03610104', 'BU03610108', 'BU03610300', 'BU03610800', 'BU03610801', 'BU03610802', 'BU03610803')
GROUP BY bu_code, section_id

----------this time we want to compare the two datasets(bgt)
SELECT 
    b.bu_code, 
    COUNT(*) AS total_parking_spots,
    COUNT(DISTINCT gml_id) AS bgt_count
FROM 
    parking_lots_points2_neighborhood a
LEFT JOIN 
    bgt_wegdeel22_neighborhood b 
    ON ST_Intersects(a.geom, b.geom)
WHERE 
    a.bu_code IN ('BU03610104', 'BU03610108', 'BU03610300', 'BU03610800', 'BU03610801', 'BU03610802', 'BU03610803')
GROUP BY 
    b.bu_code

------ ecorys
SELECT 
    a.bu_code, 
    COUNT(*) AS total_parking_spots_corys_count
    --COUNT(DISTINCT CASE WHEN c.Id IS NOT NULL THEN c.Id END) AS ecorys_count
FROM 
    parking_lots_points2_neighborhood a
LEFT JOIN 
    ecorys_alkmaar_sections2_neighborhood c 
    ON ST_Intersects(a.geom, c.geom)
    AND a.bu_code = c.bu_code
WHERE 
    a.bu_code IN ('BU03610104', 'BU03610108', 'BU03610300', 'BU03610800', 'BU03610801', 'BU03610802', 'BU03610803')
GROUP BY 
    a.bu_code;



--------- ecorys and bgt combined
SELECT 
    a.bu_code, 
    COUNT(*) AS total_parking_spots_ecorys_count,
    COUNT(DISTINCT b.gml_id) AS bgt_count--,
    --COUNT(DISTINCT c.Id) AS ecorys_count
FROM 
    parking_lots_points2_neighborhood a
LEFT JOIN 
    bgt_wegdeel22_neighborhood b 
    ON ST_Intersects(a.geom, b.geom)
LEFT JOIN 
    ecorys_alkmaar_sections2_neighborhood c 
    ON ST_Intersects(a.geom, c.geom)
WHERE 
    a.bu_code IN ('BU03610104', 'BU03610108', 'BU03610300', 'BU03610800', 'BU03610801', 'BU03610802', 'BU03610803')
GROUP BY 
    a.bu_code

-----another code output to compare bgt and ecorys when using the parking spot
SELECT DISTINCT
ml_cars_clipped.bu_code, -- Building code
section.section_id, -- Section ID
COUNT(DISTINCT a.gml_id) AS bgt_count, -- Count the distinct BGT parking spots within the section
COUNT(DISTINCT c.Id) AS ecorys_count -- Count the distinct ECORYS parking spots within the section
FROM
bgt_wegdeel22_neighborhood a
LEFT JOIN
ml_cars_clipped -- Parking spot data clipped to building polygons
ON ST_Intersects(a.geom, ml_cars_clipped.geom)
LEFT JOIN
ecorys_alkmaar_sections2_neighborhood c
ON ST_Intersects(ml_cars_clipped.geom, c.geom)
JOIN
section ON ml_cars_clipped.section_id = section.section_id -- Join with the section table based on section ID
WHERE
ml_cars_clipped.bu_code IN ('BU03610104', 'BU03610108', 'BU03610300', 'BU03610800', 'BU03610801', 'BU03610802', 'BU03610803')
GROUP BY
ml_cars_clipped.bu_code, -- Group by building code
section.section_id; -- Group by section ID

----new tables trying to seggreagate the data/tables
-- Create a new table called "compare_parking_spots"
CREATE TABLE compare_parking_spots AS 

-- Select the building code, total parking spots in parking_lots_points2_neighborhood, BGT parking spots, and ECORYS parking spots for each building code
---correct parking spots with bgt
SELECT 
    a.bu_code,
    COUNT(*) AS total_parking_spots_points2_count,
    COUNT(DISTINCT b.gml_id) AS bgt_count,
    COUNT(DISTINCT c.sectie) AS ecorys_count
FROM 
    parking_lots_points2_neighborhood a
LEFT JOIN 
    bgt_wegdeel22_neighborhood b 
    ON ST_Intersects(a.geom, b.geom)
LEFT JOIN 
    ecorys_alkmaar_sections2_neighborhood c 
    ON ST_Intersects(a.geom, c.geom)
WHERE 
    a.bu_code IN ('BU03610104', 'BU03610108', 'BU03610300', 'BU03610800', 'BU03610801', 'BU03610802', 'BU03610803')
GROUP BY 
    a.bu_code;

-- Create a new table called "compare_parking_sections"
CREATE TABLE compare_parking_sections AS 

-- Select the building code, section ID, total parking spots in BGT, and ECORYS parking spots for each building and section
----correct parking spots vs bgt vs ecorys
SELECT 
    ml_cars_clipped.bu_code, -- Building code
    section.section_id, -- Section ID
    COUNT(DISTINCT a.gml_id) AS bgt_count, -- Count the distinct BGT parking spots within the section
    COUNT(DISTINCT c.Id) AS ecorys_count -- Count the distinct ECORYS parking spots within the section
FROM 
    bgt_wegdeel22_neighborhood a
LEFT JOIN 
    ml_cars_clipped -- Parking spot data clipped to building polygons
    ON ST_Intersects(a.geom, ml_cars_clipped.geom)
LEFT JOIN 
    ecorys_alkmaar_sections2_neighborhood c 
    ON ST_Intersects(ml_cars_clipped.geom, c.geom)
JOIN 
    section ON ml_cars_clipped.section_id = section.section_id -- Join with the section table based on section ID
WHERE 
    ml_cars_clipped.bu_code IN ('BU03610104', 'BU03610108', 'BU03610300', 'BU03610800', 'BU03610801', 'BU03610802', 'BU03610803')
GROUP BY 
    ml_cars_clipped.bu_code, -- Group by building code
    section.section_id; -- Group by section ID

-- Create a new table called "compare_parking_neighborhood"
CREATE TABLE compare_parking_neighborhood AS 

-- Select the neighborhood code, total parking spots in parking_lots_points2_neighborhood, BGT parking spots, and ECORYS parking spots for each neighborhood code
SELECT 
    a.bu_code,
    COUNT(*) AS total_parking_spots_points2_count,
    COUNT(DISTINCT b.gml_id) AS bgt_count,
    COUNT(DISTINCT c.sectie) AS ecorys_count
FROM 
    parking_lots_points2_neighborhood a
LEFT JOIN 
    bgt_wegdeel22_neighborhood b 
    ON ST_Intersects(a.geom, b.geom)
LEFT JOIN 
    ecorys_alkmaar_sections2_neighborhood c 
    ON ST_Intersects(a.geom, c.geom)

-----final code
SELECT buurt_201622.bu_code, buurt_201622.bu_naam, COUNT(parking_lots_points2_neighborhood.Id) AS num_parking_spots 
FROM buurt_201622 LEFT JOIN parking_lots_points2_neighborhood ON ST_Contains(buurt_201622.geom, Parking_lots_points2_neighborhood.geom) 
WHERE buurt_201622.bu_code IN ('BU03610104', 'BU03610108', 'BU03610300', 'BU03610800', 'BU03610801', 'BU03610802', 'BU03610803') 
GROUP BY buurt_201622.bu_code, buurt_201622.bu_naam; 



---final code with the 2.5x5 condition set for parking_lots_points
-- select the neighborhood code, name, total polygon area, and estimated number of parking spots within the neighborhoods
SELECT buurt_201622.bu_code, buurt_201622.bu_naam, ST_Area(buurt_201622.geom) AS total_polygon_area, 
    ROUND(ST_Area(buurt_201622.geom)/125) AS estimated_num_parking_spots
-- join the buurt_201622 table with the parking_lots_points2_neighborhood table
FROM buurt_201622 
LEFT JOIN parking_lots_points2_neighborhood 
ON ST_Contains(buurt_201622.geom, Parking_lots_points2_neighborhood.geom) 
-- filter the neighborhoods to specific bu_code values
WHERE buurt_201622.bu_code IN ('BU03610104', 'BU03610108', 'BU03610300', 'BU03610800', 'BU03610801', 'BU03610802', 'BU03610803') 
-- group the results by bu_code and bu_naam
GROUP BY buurt_201622.bu_code, buurt_201622.bu_naam, total_polygon_area;
