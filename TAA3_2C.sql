--2C. In 2016 Alkmaar asked Ecorys to perform evening and night parking measurements. 
--Through this, the municipality wants to see how these differ per neighbourhood. 
--For instance, you can expect that in residential areas the occupancy rate will be 
--higher during the night, whereas in the city centre this might be higher during the 
--evening. It is your task to create a map of all the neighbourhoods showing the 
--differences between these measurements. To do so you will need to aggregate 
--the street section data to a neighbourhood level.

---Determine the parking measurements for evening and night
SELECT p.bu_code, p.bu_naam,p.evening,p.night from 
(SELECT buurt_2016.bu_code, buurt_2016.bu_naam,
sum(Goed2016a+BzOPR2016a+BzPT2016a) as evening,
sum(Goed2016n+BzOPR2016n+BzPT2016n) as night 
	   
FROM ecorys_alkmaar_sections
LEFT OUTER JOIN ecorys_parkingpressure_alkmaar ON ecorys_alkmaar_sections.id = ecorys_parkingpressure_alkmaar.section
JOIN buurt_2016 ON ST_Intersects(buurt_2016.geom, ecorys_alkmaar_sections.geom)
GROUP BY buurt_2016.bu_code, buurt_2016.bu_naam 
ORDER BY buurt_2016.bu_code DESC) p



--To add a spatial index to the given code, you can create a spatial index 
--on the geom column of the ecorys_combined_data2 table, which is used in the spatial join with the buurt_201622 table.
--In this modified code, we first create a spatial index on the geom column of the 
--ecorys_combined_data2 table using the CREATE INDEX statement. 
--We then modify the subquery to include a WHERE clause that uses the ST_Intersects function to filter the results using the spatial index. This can help reduce the computation time of the query.
-- create a spatial index on the geom column of the ecorys_combined_data2 table

---This code gives negative values
CREATE INDEX ecorys_combined_data2_geom_idx2 ON ecorys_combined_data2 USING GIST (geom);

-- run the query with the spatial index
SELECT p.bu_code, p.bu_naam, p.evening, p.night 
FROM 
(
    SELECT buurt_201622.bu_code, buurt_201622.bu_naam, 
        sum(Goed2016a+BzOPR2016a+BzPT2016a) as evening,
        sum(Goed2016n+BzOPR2016n+BzPT2016n) as night 
    FROM Ecorys_combined_data2
    LEFT OUTER JOIN ecorys_parkingpressure_alkmaar ON ecorys_combined_data2.id = ecorys_parkingpressure_alkmaar.section
    JOIN buurt_201622 ON ST_Intersects(buurt_201622.geom, ecorys_combined_data2.geom)
    JOIN ecorys_alkmaar_sections2 ON ecorys_combined_data2.id = ecorys_alkmaar_sections2.id -- add this join
    WHERE ST_Intersects(buurt_201622.geom, ecorys_combined_data2.geom) -- add this condition to filter using the spatial index
    GROUP BY buurt_201622.bu_code, buurt_201622.bu_naam 
    ORDER BY buurt_201622.bu_code DESC
) p;



--For TAA3 and TAA4 we provided the Ecorys data and the BGT data, which contain 
--information about parking lots. We want you to create lists of neighbourhoods (buurten) containing 
--the number of available parking spots that comes out of these datasets.
--Provide a table of neighbourhoods containing the Compare the outcomes and 
--explain possible differences.

---This code doesnt have negative values-57 results
SELECT p.bu_code, p.bu_naam, p.evening, p.night 
FROM 
(
    SELECT b.bu_code, b.bu_naam, 
        sum(d.Goed2016a+d.BzOPR2016a+d.BzPT2016a) as evening,
        sum(d.Goed2016n+d.BzOPR2016n+d.BzPT2016n) as night 
    FROM Ecorys_combined_data4 d
    LEFT OUTER JOIN ecorys_combined_data c ON d.id = c.sectie
    JOIN buurt_201622 b ON ST_Intersects(b.geom, d.geom)
    JOIN ecorys_alkmaar_sections2 s ON d.id = s.id -- add this join
    WHERE ST_Intersects(b.geom, d.geom) -- add this condition to filter using the spatial index
    GROUP BY b.bu_code, b.bu_naam 
    ORDER BY b.bu_code DESC
) p;



----same results
SELECT b.bu_code, b.bu_naam,
sum(d.Goed2016a+d.BzOPR2016a+d.BzPT2016a) as evening,
sum(d.Goed2016n+d.BzOPR2016n+d.BzPT2016n) as night
FROM Ecorys_combined_data4 d
INNER JOIN buurt_201622 b ON ST_Intersects(b.geom, d.geom)
INNER JOIN ecorys_alkmaar_sections2 s ON d.id = s.id
GROUP BY b.bu_code, b.bu_naam
ORDER BY b.bu_code DESC;

---include a map

CREATE TABLE evening_night_neigbourhood2 AS
SELECT b.bu_code, b.bu_naam, 
       SUM(d.Goed2016a+d.BzOPR2016a+d.BzPT2016a) AS evening,
       SUM(d.Goed2016n+d.BzOPR2016n+d.BzPT2016n) AS night,
       b.geom
FROM Ecorys_combined_data4 d
LEFT OUTER JOIN ecorys_combined_data c ON d.id = c.sectie
JOIN buurt_201622 b ON ST_Intersects(b.geom, d.geom)
JOIN ecorys_alkmaar_sections2 s ON d.id = s.id -- add this join
WHERE ST_Intersects(b.geom, d.geom) -- add this condition to filter using the spatial index
GROUP BY b.bu_code, b.bu_naam, b.geom
ORDER BY b.bu_code DESC;

-----include occupancy rate
SELECT 
  ecorys.Id AS entity_id, 
  SUM(ecorys.cap2016) AS parking_spots,
  SUM(evening_night_neigbourhood2.evening + evening_night_neigbourhood2.night) AS parked_cars,
  (SUM(ecorys.cap2016) - SUM(evening_night_neigbourhood2.evening + evening_night_neigbourhood2.night)) AS available_spots,
  (SUM(evening_night_neigbourhood2.evening + evening_night_neigbourhood2.night)/SUM(ecorys.cap2016))*100 AS occupancy_rate
FROM 
  ecorys_combined_data4 AS ecorys 
LEFT JOIN evening_night_neigbourhood2 ON ecorys.id = evening_night_neigbourhood2.bu_code
GROUP BY 
  ecorys.Id;


SELECT 
  ecorys.Id AS entity_id, 
  SUM(ecorys.cap2016) AS parking_spots,
  SUM(evening_night_neigbourhood2.evening + evening_night_neighbourhood2.night) AS parked_cars,
  (SUM(ecorys.cap2016) - SUM(evening_night_neighbourhood2.evening + evening_night_neighbourhood2.night)) AS available_spots,
  (SUM(evening_night_neighbourhood2.evening + evening_night_neighbourhood2.night)/SUM(ecorys.cap2016))*100 AS occupancy_rate
FROM 
  ecorys_combined_data4 AS ecorys 
LEFT JOIN evening_night_neighbourhood2 ON ecorys.id = CAST(evening_night_neighbourhood2.bu_code AS bigint)
GROUP BY 
  ecorys.Id;

----seems like the correct
CREATE TABLE evening_night_neighbourhood2 AS
SELECT b.bu_code, b.bu_naam, 
       SUM(d.Goed2016a+d.BzOPR2016a+d.BzPT2016a) AS evening,
       SUM(d.Goed2016n+d.BzOPR2016n+d.BzPT2016n) AS night,
       b.geom
FROM Ecorys_combined_data4 d
LEFT OUTER JOIN ecorys_combined_data c ON d.id = c.sectie
JOIN buurt_201622 b ON ST_Intersects(b.geom, d.geom)
JOIN ecorys_alkmaar_sections2 s ON d.id = s.id -- add this join
WHERE ST_Intersects(b.geom, d.geom) -- add this condition to filter using the spatial index
GROUP BY b.bu_code, b.bu_naam, b.geom
ORDER BY b.bu_code DESC;



------this included new merged data
SELECT b.bu_code, b.bu_naam, 
       SUM(d.Goed2016a+d.BzOPR2016a+d.BzPT2016a) AS evening,
       SUM(d.Goed2016n+d.BzOPR2016n+d.BzPT2016n) AS night,
       m.section_id,
       m.date,
       m.moment_day,
       m.correct_parked_street,
       m.incorrect_parked_street,
       m.num_cars_parking_lot,
       m.num_cars_private_driveway,
       m.capacity_street,
       m.capacity_parking_lots,
       m.capacity_private_driveways
FROM Ecorys_combined_data4 d
LEFT OUTER JOIN ecorys_combined_data c ON d.id = c.sectie
JOIN buurt_201622 b ON ST_Intersects(b.geom, d.geom)
JOIN ecorys_alkmaar_sections2 s ON d.id = s.id
JOIN merged_measurement_sections m ON m.section_id = d.id -- use section_id as the primary key to join tables
WHERE ST_Intersects(b.geom, d.geom)
GROUP BY b.bu_code, b.bu_naam, m.section_id, m.date, m.moment_day, m.correct_parked_street, m.incorrect_parked_street, m.num_cars_parking_lot, m.num_cars_private_driveway, m.capacity_street, m.capacity_parking_lots, m.capacity_private_driveways
ORDER BY b.bu_code DESC;

-----this include the geom
SELECT b.bu_code, b.bu_naam, 
       SUM(d.Goed2016a+d.BzOPR2016a+d.BzPT2016a) AS evening,
       SUM(d.Goed2016n+d.BzOPR2016n+d.BzPT2016n) AS night,
       m.section_id,
       m.date,
       m.moment_day,
       m.correct_parked_street,
       m.incorrect_parked_street,
       m.num_cars_parking_lot,
       m.num_cars_private_driveway,
       m.capacity_street,
       m.capacity_parking_lots,
       m.capacity_private_driveways,
       ST_AsGeoJSON(d.geom) AS geometry
FROM Ecorys_combined_data4 d
LEFT OUTER JOIN ecorys_combined_data c ON d.id = c.sectie
JOIN buurt_201622 b ON ST_Intersects(b.geom, d.geom)
JOIN ecorys_alkmaar_sections2 s ON d.id = s.id
JOIN merged_measurement_sections m ON m.section_id = d.id -- use section_id as the primary key to join tables
WHERE ST_Intersects(b.geom, d.geom)
GROUP BY b.bu_code, b.bu_naam, m.section_id, m.date, m.moment_day, m.correct_parked_street, m.incorrect_parked_street, m.num_cars_parking_lot, m.num_cars_private_driveway, m.capacity_street, m.capacity_parking_lots, m.capacity_private_driveways, d.geom
ORDER BY b.bu_code DESC;

-----occupancy rate in evening and night but not intuitive

SELECT b.bu_code, b.bu_naam, 
       SUM(d.Goed2016a+d.BzOPR2016a+d.BzPT2016a) AS evening,
       SUM(d.Goed2016n+d.BzOPR2016n+d.BzPT2016n) AS night,
       m.section_id,
       m.date,
       m.moment_day,
       m.correct_parked_street,
       m.incorrect_parked_street,
       m.num_cars_parking_lot,
       m.num_cars_private_driveway,
       m.capacity_street,
       m.capacity_parking_lots,
       m.capacity_private_driveways,
       ((SUM(d.Goed2016n+d.BzOPR2016n+d.BzPT2016n) - SUM(d.Goed2016a+d.BzOPR2016a+d.BzPT2016a)) / total_spots.total * 100) AS occupancy_rate_difference
FROM Ecorys_combined_data4 d
LEFT OUTER JOIN ecorys_combined_data c ON d.id = c.sectie
JOIN buurt_201622 b ON ST_Intersects(b.geom, d.geom)
JOIN ecorys_alkmaar_sections2 s ON d.id = s.id
JOIN merged_measurement_sections m ON m.section_id = d.id
JOIN (SELECT section_id, SUM(capacity_street+capacity_parking_lots+capacity_private_driveways) AS total FROM merged_measurement_sections GROUP BY section_id) AS total_spots ON m.section_id = total_spots.section_id
WHERE ST_Intersects(b.geom, d.geom) AND (m.moment_day = 'night' OR m.moment_day = 'evening')
GROUP BY b.bu_code, b.bu_naam, m.section_id, m.date, m.moment_day, m.correct_parked_street, m.incorrect_parked_street, m.num_cars_parking_lot, m.num_cars_private_driveway, m.capacity_street, m.capacity_parking_lots, m.capacity_private_driveways, total_spots.total
ORDER BY b.bu_code DESC;

------ -----occupancy rate in evening and night
SELECT
  section.section_id,
  merged_measurement_sections.moment_day,
  COALESCE(SUM(capacity.capacity_street + capacity.capacity_parking_lots + capacity.capacity_private_driveways), 0) AS total_capacity,
  COUNT(ml_cars_clipped.*) AS parked_cars,
  COALESCE(COUNT(ml_cars_clipped.*)::FLOAT / NULLIF(SUM(capacity.capacity_street + capacity.capacity_parking_lots + capacity.capacity_private_driveways), 0), 0.0) AS occupancy_rate
FROM
  section
LEFT JOIN
  capacity ON section.section_id = capacity.section_id
LEFT JOIN
  ml_cars_clipped ON section.section_id = ml_cars_clipped.section_id
LEFT JOIN
  merged_measurement_sections ON section.section_id = merged_measurement_sections.section_id AND (date_trunc('day', merged_measurement_sections.date) = '2016-01-01' OR (merged_measurement_sections.moment_day = 'night' AND merged_measurement_sections.date BETWEEN '2014-01-01' AND '2015-12-31'))
GROUP BY
  section.section_id, merged_measurement_sections.moment_day;

------
----- for evening only
SELECT
  section.section_id,
  merged_measurement_sections.moment_day,
  SUM(capacity.capacity_street + capacity.capacity_parking_lots + capacity.capacity_private_driveways) AS total_capacity,
  COUNT(ml_cars_clipped.*) AS parked_cars,
  COALESCE(COUNT(ml_cars_clipped.*)::FLOAT / NULLIF(SUM(capacity.capacity_street + capacity.capacity_parking_lots + capacity.capacity_private_driveways), 0), 0.0) AS occupancy_rate
FROM
  section
LEFT JOIN
  capacity ON section.section_id = capacity.section_id
LEFT JOIN
  ml_cars_clipped ON section.section_id = ml_cars_clipped.section_id
LEFT JOIN
  merged_measurement_sections ON section.section_id = merged_measurement_sections.section_id AND date_trunc('day', merged_measurement_sections.date) = '2016-01-01'
GROUP BY
  section.section_id, merged_measurement_sections.moment_day;

---evening only on the map
create table eveningonly_occupancy_rate as
SELECT
  section.section_id,
  merged_measurement_sections.moment_day,
  SUM(capacity.capacity_street + capacity.capacity_parking_lots + capacity.capacity_private_driveways) AS total_capacity,
  COUNT(ml_cars_clipped.*) AS parked_cars,
  COALESCE(COUNT(ml_cars_clipped.*)::FLOAT / NULLIF(SUM(capacity.capacity_street + capacity.capacity_parking_lots + capacity.capacity_private_driveways), 0), 0.0) AS occupancy_rate,
  ml_cars_clipped.geom AS car_geom,
  ml_cars_clipped.bu_code,
  ml_cars_clipped.bu_naam
FROM
  section
LEFT JOIN
  capacity ON section.section_id = capacity.section_id
LEFT JOIN
  ml_cars_clipped ON section.section_id = ml_cars_clipped.section_id
LEFT JOIN
  merged_measurement_sections ON section.section_id = merged_measurement_sections.section_id AND date_trunc('day', merged_measurement_sections.date) = '2016-01-01'
GROUP BY
  section.section_id, merged_measurement_sections.moment_day, ml_cars_clipped.geom, ml_cars_clipped.bu_code, ml_cars_clipped.bu_naam;

-----evening and night occupancy with map final
create table evening_night_occupancy_rate as
SELECT
  section.section_id,
  merged_measurement_sections.moment_day,
  COALESCE(SUM(capacity.capacity_street + capacity.capacity_parking_lots + capacity.capacity_private_driveways), 0) AS total_capacity,
  COUNT(ml_cars_clipped.*) AS parked_cars,
  COALESCE(COUNT(ml_cars_clipped.*)::FLOAT / NULLIF(SUM(capacity.capacity_street + capacity.capacity_parking_lots + capacity.capacity_private_driveways), 0), 0.0) AS occupancy_rate,
  ml_cars_clipped.geom,
  ml_cars_clipped.bu_code,
  ml_cars_clipped.bu_naam
FROM
  section
LEFT JOIN
  capacity ON section.section_id = capacity.section_id
LEFT JOIN
  ml_cars_clipped ON section.section_id = ml_cars_clipped.section_id
LEFT JOIN
  merged_measurement_sections ON section.section_id = merged_measurement_sections.section_id AND (date_trunc('day', merged_measurement_sections.date) = '2016-01-01' OR (merged_measurement_sections.moment_day = 'night' AND merged_measurement_sections.date >= '2014-01-01'))
GROUP BY
  section.section_id, merged_measurement_sections.moment_day, ml_cars_clipped.geom, 
  ml_cars_clipped.bu_code, ml_cars_clipped.bu_naam;

-----extra code also seems to make sense
SELECT
  merged_measurement_sections.section_id,
  merged_measurement_sections.moment_day,
  SUM(capacity.capacity_street + capacity.capacity_parking_lots + capacity.capacity_private_driveways) AS total_capacity,
  COUNT(ml_cars_clipped.*) AS parked_cars,
  COALESCE(COUNT(ml_cars_clipped.*)::FLOAT / NULLIF(SUM(capacity.capacity_street + capacity.capacity_parking_lots + capacity.capacity_private_driveways), 0), 0.0) AS occupancy_rate,
  ml_cars_clipped.bu_code,
  ml_cars_clipped.bu_naam
FROM
  capacity
LEFT JOIN
  ml_cars_clipped ON capacity.section_id = ml_cars_clipped.section_id
INNER JOIN
  merged_measurement_sections ON capacity.section_id = merged_measurement_sections.section_id
GROUP BY
  merged_measurement_sections.section_id, merged_measurement_sections.moment_day, ml_cars_clipped.bu_code, ml_cars_clipped.bu_naam;
