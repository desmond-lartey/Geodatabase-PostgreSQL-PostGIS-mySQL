--1. Parking capacity
--1A: The municipality of Alkmaar wants to know the total parking capacity per neighbourhood. 
--In order to do so they have multiple sources available.
--For TAA3 and TAA4 we provided the Ecorys data and the BGT data, which contain 
--information about parking lots. We want you to create lists of neighbourhoods (buurten) containing 
--the number of available parking spots that comes out of these datasets.
--Provide a table of neighbourhoods containing the Compare the outcomes and 
--explain possible differences.

----bgt final but repeated rows
CREATE TABLE compare_carparking_bgt AS
SELECT ml_cars_clipped.bu_code, ml_cars_clipped.bu_naam, section.section_id, 
SUM(ST_Area(ml_cars_clipped.geom)) / 125 AS num_parking_spots,
ROUND(SUM(ST_Area(ml_cars_clipped.geom)) / 125) AS est_num_parking_spots
FROM ml_cars_clipped
JOIN section ON ml_cars_clipped.section_id = section.section_id
JOIN bgt_wegdeel22_neighborhood ON ST_Intersects(ml_cars_clipped.geom, bgt_wegdeel22_neighborhood.geom)
GROUP BY ml_cars_clipped.bu_code, ml_cars_clipped.bu_naam, section.section_id;


------bgt final but not repeated
CREATE TABLE compare_carparking_bgt AS 
SELECT DISTINCT ON (ml_cars_clipped.bu_code, ml_cars_clipped.bu_naam)
  ml_cars_clipped.bu_code, -- Building code
  ml_cars_clipped.bu_naam, -- Building name
  --bgt_wegdeel22_neighborhood.bu_naam, -- Neighborhood name
  section.section_id, -- Section ID
  SUM(ST_Area(ml_cars_clipped.geom)) / 125 AS num_parking_spots, -- Calculate the total area of parking spots and divide by 125 to estimate the number of parking spots
  ROUND(SUM(ST_Area(ml_cars_clipped.geom)) / 125) AS est_num_parking_spots -- Round the estimated number of parking spots to the nearest integer
FROM 
  ml_cars_clipped -- Parking spot data clipped to building polygons
  JOIN section ON ml_cars_clipped.section_id = section.section_id -- Join with the section table based on section ID
  JOIN bgt_wegdeel22_neighborhood ON ST_Intersects(ml_cars_clipped.geom, bgt_wegdeel22_neighborhood.geom) -- Join with the neighborhood table based on the intersection of geometries
GROUP BY 
  ml_cars_clipped.bu_code, -- Group by building code
  ml_cars_clipped.bu_naam, -- Group by building name
  --bgt_wegdeel22_neighborhood.bu_naam, -- Group by neighborhood name
  section.section_id -- Group by section ID
ORDER BY 
  ml_cars_clipped.bu_code, ml_cars_clipped.bu_naam, est_num_parking_spots DESC;

------
CREATE INDEX ml_cars_clipped_geom_idx ON ml_cars_clipped USING GIST (geom);
CREATE INDEX bgt_wegdeel22_neighborhood_geom_idx ON bgt_wegdeel22_neighborhood USING GIST (geom);

SELECT b.gml_id, b.bu_code, b.bu_naam, SUM(ST_Area(a.geom)) AS total_area, 
  (SUM(ST_Area(a.geom)) / 125) * 10 AS estimated_parking_spots
FROM ml_cars_clipped a
JOIN bgt_wegdeel22_neighborhood b
ON a.bu_code = b.bu_code
GROUP BY b.gml_id, b.bu_code, b.bu_naam;

-----take longer code
SELECT 
    ml_cars_clipped.bu_code,
    ml_cars_clipped.bu_naam,
    bgt_wegdeel22_neighborhood.geom,
    SUM(section.capacity_street + section.capacity_parking_lots + section.capacity_private_driveways) AS total_capacity,
    ROUND(ST_Area(bgt_wegdeel22_neighborhood.geom) / 125) AS parking_spots,
    ROUND(SUM(section.capacity_street + section.capacity_parking_lots + section.capacity_private_driveways) * ST_Area(bgt_wegdeel22_neighborhood.geom) / (125 * 10)) AS estimated_cars
FROM 
    ml_cars_clipped
    JOIN section ON ml_cars_clipped.section_id = section.section_id
    JOIN bgt_wegdeel22_neighborhood ON ml_cars_clipped.bu_code = bgt_wegdeel22_neighborhood.bu_code
GROUP BY 
    ml_cars_clipped.bu_code,
    ml_cars_clipped.bu_naam,
    bgt_wegdeel22_neighborhood.geom


----Ecorys data: The parking capacity measurements performed by Ecorys between 
--2014-2016 contain, besides the number of parked cars, also various fields with
--the available capacity. The municipality wants you to create a list contain the 
--total number of parking spots per neighbourhood. Please note, that not every 
--section has been measured in every scan and some have been measured twice, in which case we want to most recent observation.
--Provide a table of neighbourhoods containing the Compare the outcomes and 
--explain possible differences.

---ecorys final but repeated neighbouhood rows
create table compare_carparking_ecorys as
SELECT ml_cars_clipped.bu_code, ml_cars_clipped.bu_naam, section.section_id, 
SUM(ST_Area(ml_cars_clipped.geom)) / 125 as num_parking_spots,
ROUND(SUM(ST_Area(ml_cars_clipped.geom)) / 125) as est_num_parking_spots
FROM ml_cars_clipped
JOIN section ON ml_cars_clipped.section_id = section.section_id
GROUP BY ml_cars_clipped.bu_code, ml_cars_clipped.bu_naam, section.section_id;

---- ecorys final but not repeated neighbouhood rows
CREATE TABLE compare_carparking_ecorys AS
SELECT DISTINCT ON (ml_cars_clipped.bu_code, ml_cars_clipped.bu_naam)
    ml_cars_clipped.bu_code, 
    ml_cars_clipped.bu_naam, 
    section.section_id, 
    SUM(ST_Area(ml_cars_clipped.geom)) / 125 AS num_parking_spots,
    ROUND(SUM(ST_Area(ml_cars_clipped.geom)) / 125) AS est_num_parking_spots
FROM ml_cars_clipped
JOIN section ON ml_cars_clipped.section_id = section.section_id
GROUP BY ml_cars_clipped.bu_code, ml_cars_clipped.bu_naam, section.section_id
ORDER BY ml_cars_clipped.bu_code, ml_cars_clipped.bu_naam, est_num_parking_spots DESC;



------
SELECT ml_cars_clipped.bu_code, ml_cars_clipped.bu_naam, section.section_id, 
SUM(ST_Area(ml_cars_clipped.geom)) / 125 as num_parking_spots,
ROUND(SUM(ST_Area(ml_cars_clipped.geom)) / 125) as est_num_parking_spots
FROM ml_cars_clipped
JOIN section ON ml_cars_clipped.section_id = section.section_id
GROUP BY ml_cars_clipped.bu_code, ml_cars_clipped.bu_naam, section.section_id;

-------
SELECT ml_cars_clipped.bu_code, ml_cars_clipped.bu_naam, section.section_id, 
SUM(ST_Area(ml_cars_clipped.geom)) / 125 as num_parking_spots,
ROUND(SUM(ST_Area(ml_cars_clipped.geom)) / 125) as est_num_parking_spots
FROM ml_cars_clipped
JOIN section ON ml_cars_clipped.section_id = section.section_id
GROUP BY ml_cars_clipped.bu_code, ml_cars_clipped.bu_naam, section.section_id;

------
SELECT bu_naam AS neighborhood, 
       SUM(COALESCE(capacity_street, 0) + COALESCE(capacity_parking_lots, 0) + COALESCE(capacity_private_driveways, 0)) AS total_parking_spots,
       ROUND(SUM(ST_Area(geom))/125) AS estimated_parking_spots
FROM section
LEFT JOIN (
    SELECT DISTINCT ON (section_id) section_id, 
           confidence, 
           bu_code, 
           bu_naam, 
           geom 
    FROM ml_cars_clipped
    ORDER BY section_id, confidence DESC
) AS ml_cars_clipped_most_recent
ON section.section_id = ml_cars_clipped_most_recent.section_id
GROUP BY bu_naam;

-------
SELECT bu_naam AS neighborhood, 
       SUM(COALESCE(capacity_street, 0) + COALESCE(capacity_parking_lots, 0) + COALESCE(capacity_private_driveways, 0)) AS total_parking_spots
FROM section
LEFT JOIN (
    SELECT DISTINCT ON (section_id) section_id, 
           confidence, 
           bu_code, 
           bu_naam, 
           geom 
    FROM ml_cars_clipped
    ORDER BY section_id, confidence DESC
) AS ml_cars_clipped_most_recent
ON section.section_id = ml_cars_clipped_most_recent.section_id
GROUP BY bu_naam;

------
SELECT bu_naam AS neighborhood, 
       SUM(COALESCE(capacity_street, 0) + COALESCE(capacity_parking_lots, 0) + COALESCE(capacity_private_driveways, 0)) AS total_parking_spots,
       ROUND(SUM(ST_Area(geom))/125) AS estimated_parking_spots
FROM section
LEFT JOIN (
    SELECT DISTINCT ON (section_id) section_id, 
           confidence, 
           bu_code, 
           bu_naam, 
           geom 
    FROM ml_cars_clipped
    ORDER BY section_id, confidence DESC
) AS ml_cars_clipped_most_recent
ON section.section_id = ml_cars_clipped_most_recent.section_id
GROUP BY bu_naam;

-------
SELECT ml_cars_clipped.bu_code, ml_cars_clipped.bu_naam, section.section_id, 
SUM(ST_Area(ml_cars_clipped.geom)) / 125 as num_parking_spots,
ROUND(SUM(ST_Area(ml_cars_clipped.geom)) / 125) as est_num_parking_spots
FROM ml_cars_clipped
JOIN section ON ml_cars_clipped.section_id = section.section_id
GROUP BY ml_cars_clipped.bu_code, ml_cars_clipped.bu_naam, section.section_id;

------- but with bgt included
CREATE TABLE compare_carparking_ecorys AS
SELECT ml_cars_clipped.bu_code, ml_cars_clipped.bu_naam, section.section_id, 
SUM(ST_Area(ml_cars_clipped.geom)) / 125 AS num_parking_spots,
ROUND(SUM(ST_Area(ml_cars_clipped.geom)) / 125) AS est_num_parking_spots,
bgt_wegdeel22_neighborhood.gml_id, bgt_wegdeel22_neighborhood.geom
FROM ml_cars_clipped
JOIN section ON ml_cars_clipped.section_id = section.section_id
JOIN bgt_wegdeel22_neighborhood ON ST_Intersects(ml_cars_clipped.geom, bgt_wegdeel22_neighborhood.geom)
GROUP BY ml_cars_clipped.bu_code, ml_cars_clipped.bu_naam, section.section_id, bgt_wegdeel22_neighborhood.gml_id, bgt_wegdeel22_neighborhood.geom;

----- first code cars and section
SELECT ml_cars_clipped.bu_code, ml_cars_clipped.bu_naam, section.section_id, 
SUM(ST_Area(ml_cars_clipped.geom)) / 125 as num_parking_spots,
ROUND(SUM(ST_Area(ml_cars_clipped.geom)) / 125) as est_num_parking_spots
FROM ml_cars_clipped
JOIN section ON ml_cars_clipped.section_id = section.section_id
GROUP BY ml_cars_clipped.bu_code, ml_cars_clipped.bu_naam, section.section_id;


------


