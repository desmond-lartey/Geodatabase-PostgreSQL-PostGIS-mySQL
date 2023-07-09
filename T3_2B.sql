----2B. Next, the municipality wants to know how private car ownership relates 
---to the number of parked cars in the different neighbourhoods. 
--To analyse this, they want you to compare the number of owned cars per neighbourhood
---(which can be found in the Buurt_2016.shp CBS data) with the total number of parked cars. 
--Provide a list of neighbourhoods with the number of owned cars compared with 
--the total number of parked cars. 
--In addition, they request a map of Alkmaar showing the share of owned cars 
--in relation to the number of parked cars per neighbourhood.

SELECT b.bu_naam, b.auto_tot, COUNT(m.id) as parked_cars_count, 
       COUNT(CASE WHEN m.class='car' AND m.confidence>=0.5 THEN 1 END) as owned_cars_count
FROM buurt_201622 b
LEFT JOIN ml_cars2 m
ON ST_Intersects(b.geom, m.geom)
GROUP BY b.bu_naam, b.auto_tot
ORDER BY owned_cars_count DESC

-----with a ratio

SELECT 
    b.bu_naam, 
    b.auto_tot AS owned_cars, 
    COUNT(m.id) AS parked_cars, 
    (b.auto_tot / COUNT(m.id)) AS owned_to_parked_ratio
FROM 
    ml_cars2 AS m 
    JOIN buurt_201622 AS b 
        ON ST_Contains(b.geom, m.geom) 
GROUP BY 
    b.bu_naam, b.auto_tot


-----without ratio
SELECT 
    b.bu_naam, 
    b.auto_tot AS owned_cars, 
    COUNT(m.id) AS parked_cars
FROM 
    ml_cars2 AS m 
    JOIN buurt_201622 AS b 
        ON ST_Contains(b.geom, m.geom) 
GROUP BY 
    b.bu_naam, b.auto_tot

----combine with and without ratio
create table private_cars_parkedcars as
SELECT 
    subq.bu_naam, 
    subq.owned_cars, 
    subq.parked_cars,
    (subq.owned_cars / subq.parked_cars) AS owned_to_parked_ratio
FROM 
    (SELECT 
        b.bu_naam, 
        b.auto_tot AS owned_cars, 
        COUNT(m.id) AS parked_cars
    FROM 
        ml_cars2 AS m 
        JOIN buurt_201622 AS b 
            ON ST_Contains(b.geom, m.geom) 
    GROUP BY 
        b.bu_naam, b.auto_tot) AS subq

----display the map
create table private_cars_parkedcarsmap as
SELECT 
    subq.bu_naam, 
    subq.owned_cars, 
    subq.parked_cars,
    (subq.owned_cars / subq.parked_cars) AS owned_to_parked_ratio,
    b.geom
FROM 
    (SELECT 
        b.bu_naam, 
        b.auto_tot AS owned_cars, 
        COUNT(m.id) AS parked_cars
    FROM 
        ml_cars2 AS m 
        JOIN buurt_201622 AS b 
            ON ST_Contains(b.geom, m.geom) 
    GROUP BY 
        b.bu_naam, b.auto_tot) AS subq
    JOIN buurt_201622 AS b 
        ON subq.bu_naam = b.bu_naam



---without ratio
SELECT
  buurt_201622.bu_code,
  buurt_201622.bu_naam,
  SUM(buurt_201622.auto_tot) AS num_owned_cars,
  SUM(merged_measurement_sections.num_cars_parking_lot + merged_measurement_sections.num_cars_private_driveway) AS num_parked_cars
FROM
  ml_cars_clipped
  INNER JOIN merged_measurement_sections ON ml_cars_clipped.section_id = merged_measurement_sections.section_id
  INNER JOIN buurt_201622 ON ml_cars_clipped.bu_code = buurt_201622.bu_code
GROUP BY
  buurt_201622.bu_code,
  buurt_201622.bu_naam;


----- with ratio from new merged data but quite qestionable big ratio but maybe 
--because its a combined data
SELECT
buurt_201622.bu_code,
buurt_201622.bu_naam,
SUM(buurt_201622.auto_tot) AS num_owned_cars,
SUM(merged_measurement_sections.num_cars_parking_lot + merged_measurement_sections.num_cars_private_driveway) AS num_parked_cars,
SUM(buurt_201622.auto_tot) / NULLIF(SUM(merged_measurement_sections.num_cars_parking_lot + merged_measurement_sections.num_cars_private_driveway), 0) AS car_ratio
FROM
ml_cars_clipped
INNER JOIN merged_measurement_sections ON ml_cars_clipped.section_id = merged_measurement_sections.section_id
INNER JOIN buurt_201622 ON ml_cars_clipped.bu_code = buurt_201622.bu_code
GROUP BY
buurt_201622.bu_code,
buurt_201622.bu_naam;

----try updated query
SELECT b.bu_code, b.bu_naam, b.AUTO_TOT, 
       sum(m.correct_parked_street + m.incorrect_parked_street + 
           m.num_cars_parking_lot + m.num_cars_private_driveway) as total_parked_cars
FROM buurt_201622 b
LEFT JOIN merged_measurement_sections m ON b.bu_code = CAST(m.section_id as varchar)
GROUP BY b.bu_code, b.bu_naam, b.AUTO_TOT;


---new query also display on the map


CREATE TABLE private_cars_parkedcarsmap2 AS
-- Create a new table called private_cars_parkedcarsmap2
SELECT
  -- Select the neighborhood code, neighborhood name, and geometry
  buurt_201622.bu_code,
  buurt_201622.bu_naam,
  buurt_201622.geom,
  -- Calculate the total number of owned cars in each neighborhood
  SUM(buurt_201622.auto_tot) AS num_owned_cars,
  -- Calculate the total number of parked cars in each neighborhood
  SUM(merged_measurement_sections.num_cars_parking_lot + merged_measurement_sections.num_cars_private_driveway) AS num_parked_cars,
  -- Calculate the ratio of owned cars to parked cars in each neighborhood
  SUM(buurt_201622.auto_tot) / NULLIF(SUM(merged_measurement_sections.num_cars_parking_lot + merged_measurement_sections.num_cars_private_driveway), 0) AS car_ratio
FROM
  -- Join the ml_cars_clipped table with the merged_measurement_sections table
  ml_cars_clipped
  INNER JOIN merged_measurement_sections ON ml_cars_clipped.section_id = merged_measurement_sections.section_id
  -- Join the result with the buurt_201622 table
  INNER JOIN buurt_201622 ON ml_cars_clipped.bu_code = buurt_201622.bu_code
GROUP BY
  -- Group the result by neighborhood code, neighborhood name, and geometry
  buurt_201622.bu_code,
  buurt_201622.bu_naam,
  buurt_201622.geom
ORDER BY
  -- Order the result by car ratio in descending order
  car_ratio DESC;


-----copied from occupancy rate
---without ratio
SELECT
  buurt_201622.bu_code,
  buurt_201622.bu_naam,
  SUM(buurt_201622.auto_tot) AS num_owned_cars,
  SUM(merged_measurement_sections.num_cars_parking_lot + merged_measurement_sections.num_cars_private_driveway) AS num_parked_cars
FROM
  ml_cars_clipped
  INNER JOIN merged_measurement_sections ON ml_cars_clipped.section_id = merged_measurement_sections.section_id
  INNER JOIN buurt_201622 ON ml_cars_clipped.bu_code = buurt_201622.bu_code
GROUP BY
  buurt_201622.bu_code,
  buurt_201622.bu_naam;


----- with ratio from merged data but quite qestionable
SELECT
buurt_201622.bu_code,
buurt_201622.bu_naam,
SUM(buurt_201622.auto_tot) AS num_owned_cars,
SUM(merged_measurement_sections.num_cars_parking_lot + merged_measurement_sections.num_cars_private_driveway) AS num_parked_cars,
SUM(buurt_201622.auto_tot) / NULLIF(SUM(merged_measurement_sections.num_cars_parking_lot + merged_measurement_sections.num_cars_private_driveway), 0) AS car_ratio
FROM
ml_cars_clipped
INNER JOIN merged_measurement_sections ON ml_cars_clipped.section_id = merged_measurement_sections.section_id
INNER JOIN buurt_201622 ON ml_cars_clipped.bu_code = buurt_201622.bu_code
GROUP BY
buurt_201622.bu_code,
buurt_201622.bu_naam;

-----these are good codes and nice outputs but don't include car ratio
SELECT b.bu_code, b.bu_naam, b.AUTO_TOT, 
       COALESCE(m.total_parked_cars, 0) as total_parked_cars
FROM buurt_201622 b
LEFT JOIN (
    SELECT section_id, sum(correct_parked_street + incorrect_parked_street + num_cars_parking_lot + num_cars_private_driveway) as total_parked_cars
    FROM merged_measurement_sections
    GROUP BY section_id
) m ON b.bu_code = CAST(m.section_id as varchar)


SELECT b.bu_code, b.bu_naam, b.AUTO_TOT,
CASE WHEN b.AUTO_TOT = 0 THEN NULL ELSE ROUND((SELECT COUNT(*) FROM capacity WHERE capacity.section_id = m.section_id)::NUMERIC / b.AUTO_TOT::NUMERIC, 2) END AS parked_cars_to_owned_cars_ratio
FROM buurt_201622 b
LEFT JOIN merged_measurement_sections m ON b.bu_code = CAST(m.section_id as varchar)
LEFT JOIN capacity c ON m.section_id = c.section_id
WHERE m.section_id IS NULL;
