create table ml_cars_clipped as
SELECT c.*
FROM ml_cars2_neighborhood c
JOIN bgt_wegdeel22_neighborhood b
ON ST_Intersects(c.geom, b.geom)


CREATE INDEX ml_cars_clipped_geom_idx ON ml_cars_clipped USING GIST (geom);

UPDATE ml_cars_clipped 
SET geom = ST_Difference(geom, (
  SELECT ST_Union(ST_Intersection(b.geom, m.geom))
  FROM bgt_wegdeel22_neighborhood AS b
  JOIN ml_cars_clipped AS m ON ST_Intersects(b.geom, m.geom)
  WHERE b.geom && m.geom -- add spatial index query optimization
))
WHERE ST_GeometryType(geom) = 'MULTIPOLYGON';

UPDATE ml_cars_clipped 
SET geom = ST_Multi(geom)
WHERE ST_GeometryType(geom) = 'POLYGON';


ALTER TABLE ml_cars_clipped
ADD COLUMN section_id INTEGER;

UPDATE ml_cars_clipped 
SET section_id = s.id
FROM ecorys_alkmaar_sections2_neighborhood AS s
WHERE ST_Intersects(ml_cars_clipped.geom, s.geom);


----street per cars
SELECT s.id AS section_id, COUNT(*) AS car_count
FROM ml_cars_clipped AS m
JOIN ecorys_alkmaar_sections2_neighborhood AS s ON ST_Intersects(m.geom, s.geom)
GROUP BY s.id;
