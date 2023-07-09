----2A I am interested in the occupancy rate of parked cars. 
--The occupancy rate is calculated by dividing the number of parked cars 
--by the number available parking spots per spatial entity 
--(e.g. street section, set of street sections neighbourhood etc.). 
--I also want to have good overview on the occupation rate per neighbourhood. 
--I want you to create a list with the mean and median of the occupancy rate per neighbourhood. 
--Note that in case of overlapping observations use the most recent one.

----litle  by litle
create table parking_spots_per_entity as
SELECT 
  ecorys.Id AS entity_id, 
  SUM(ecorys.cap2016) AS parking_spots
FROM 
  ecorys_combined_data4 AS ecorys 
GROUP BY 
  ecorys.Id;


-------this gave some results
SELECT
    ec.sectie,
    sum(ec.cap2014 + ec.cap2015 + ec.cap2016) as total_parking_spots,
    count(mc.id) as parked_cars,
    count(mc.id)/(sum(ec.cap2014 + ec.cap2015 + ec.cap2016)) as occupancy_rate
FROM
    ecorys_combined_data4 ec
JOIN
    parking_spots_per_entity pc ON ec.sectie = pc.entity_id
JOIN
    ml_cars2 mc ON pc.entity_id = mc.id
GROUP BY
    ec.sectie;

----Parking spots per street entity
SELECT 
  ecorys.Id AS entity_id, 
  SUM(ecorys.cap2016) AS parking_spots
FROM 
  ecorys_combined_data4 AS ecorys 
GROUP BY 
  ecorys.Id;



----- occupancy rate
SELECT
  section.section_id,
  SUM(section.capacity_street + section.capacity_parking_lots + section.capacity_private_driveways) AS total_capacity,
  COUNT(ml_cars_clipped.*) AS parked_cars,
  COALESCE(COUNT(ml_cars_clipped.*)::FLOAT / NULLIF(SUM(section.capacity_street + section.capacity_parking_lots + section.capacity_private_driveways), 0), 0.0) AS occupancy_rate
FROM
  section
LEFT JOIN
  ml_cars_clipped ON section.section_id = ml_cars_clipped.section_id
GROUP BY
  section.section_id;

---occupancy rate with capacity table added to the calculations final(also same as above)
SELECT
  section.section_id,
  SUM(capacity.capacity_street + capacity.capacity_parking_lots + capacity.capacity_private_driveways) AS total_capacity,
  COUNT(ml_cars_clipped.*) AS parked_cars,
  COALESCE(COUNT(ml_cars_clipped.*)::FLOAT / NULLIF(SUM(capacity.capacity_street + capacity.capacity_parking_lots + capacity.capacity_private_driveways), 0), 0.0) AS occupancy_rate
FROM
  section
LEFT JOIN
  capacity ON section.section_id = capacity.section_id
LEFT JOIN
  ml_cars_clipped ON section.section_id = ml_cars_clipped.section_id
GROUP BY
  section.section_id;
  
----------------------Mean and median occupancy rate per neighborhood final
WITH occupancy_rates AS (
    SELECT
        section.section_id,
        SUM(capacity.capacity_street + capacity.capacity_parking_lots + capacity.capacity_private_driveways) AS total_capacity,
        COUNT(ml_cars_clipped) AS parked_cars,
        COALESCE(COUNT(ml_cars_clipped)::FLOAT / NULLIF(SUM(capacity.capacity_street + capacity.capacity_parking_lots + capacity.capacity_private_driveways), 0), 0.0) AS occupancy_rate
    FROM
        section
        LEFT JOIN capacity ON section.section_id = capacity.section_id
        LEFT JOIN ml_cars_clipped ON section.section_id = ml_cars_clipped.section_id
    GROUP BY
        section.section_id
)

SELECT
    ecorys_alkmaar_sections2_neighborhood.bu_code,
    ecorys_alkmaar_sections2_neighborhood.bu_naam,
    AVG(occupancy_rate) AS mean_occupancy_rate,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY occupancy_rate) AS median_occupancy_rate
FROM
    ecorys_alkmaar_sections2_neighborhood
    LEFT JOIN section ON ecorys_alkmaar_sections2_neighborhood.sectie = section.section_id
    LEFT JOIN occupancy_rates ON section.section_id = occupancy_rates.section_id
    LEFT JOIN capacity ON section.section_id = capacity.section_id
GROUP BY
    ecorys_alkmaar_sections2_neighborhood.bu_code, ecorys_alkmaar_sections2_neighborhood.bu_naam
ORDER BY
    mean_occupancy_rate DESC, median_occupancy_rate DESC;

-------mean and median new(take longer to execute) wierd results(mean same as median)
SELECT
  section.section_id,
  AVG(occupancy_rate) AS mean_occupancy_rate,
  (
    SELECT
      PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY occupancy_rate)
    FROM (
      SELECT
        section.section_id,
        COALESCE(COUNT(ml_cars_clipped.*)::FLOAT / NULLIF(SUM(section.capacity_street + section.capacity_parking_lots + section.capacity_private_driveways), 0), 0.0) AS occupancy_rate
      FROM
        section
      LEFT JOIN
        ml_cars_clipped ON section.section_id = ml_cars_clipped.section_id
      GROUP BY
        section.section_id
    ) AS occupancy_rates
    WHERE section.section_id = occupancy_rates.section_id
  ) AS median_occupancy_rate
FROM (
  SELECT
    section.section_id,
    COALESCE(COUNT(ml_cars_clipped.*)::FLOAT / NULLIF(SUM(section.capacity_street + section.capacity_parking_lots + section.capacity_private_driveways), 0), 0.0) AS occupancy_rate
  FROM
    section
  LEFT JOIN
    ml_cars_clipped ON section.section_id = ml_cars_clipped.section_id
  GROUP BY
    section.section_id
) AS occupancy_rates
JOIN
  section ON section.section_id = occupancy_rates.section_id
GROUP BY
  section.section_id;

----mean and median occupancy aggregated/for all combined
WITH occupancy_rates AS (
  SELECT
    section.section_id,
    SUM(capacity.capacity_street + capacity.capacity_parking_lots + capacity.capacity_private_driveways) AS total_capacity,
    COUNT(ml_cars_clipped.*) AS parked_cars,
    COALESCE(COUNT(ml_cars_clipped.*)::FLOAT / NULLIF(SUM(capacity.capacity_street + capacity.capacity_parking_lots + capacity.capacity_private_driveways), 0), 0.0) AS occupancy_rate
  FROM
    section
  LEFT JOIN
    capacity ON section.section_id = capacity.section_id
  LEFT JOIN
    ml_cars_clipped ON section.section_id = ml_cars_clipped.section_id
  GROUP BY
    section.section_id
)
SELECT
  AVG(occupancy_rate) AS mean_occupancy_rate,
  PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY occupancy_rate) AS median_occupancy_rate
FROM
  occupancy_rates;




