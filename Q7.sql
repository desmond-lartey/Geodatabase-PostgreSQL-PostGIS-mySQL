
---Question 1 organizers want to have three lists of films that were in Dutch cinemas 
--between 1900- 1910, 1911-1920 and 1921-1930  as inspiration for their festival program.
SELECT tblfilm.title,tblprogramme.programme_date
from tblfilm,tblprogramme
limit 500;

CREATE TABLE newfilm_1900_1910
AS
select programme_date, country, title, venue_type, name
FROM tblvenue, tblfilm
JOIN tblprogrammeitem ON tblprogrammeitem.film_id::text = tblfilm.film_id::text
JOIN tblprogramme ON tblprogramme.programme_id::text = tblprogrammeitem.programme_id::text
WHERE tblprogramme.programme_date >= '1900-01-01 00:00:00' AND tblprogramme.programme_date <= '1910-01-01 00:00:00' AND tblfilm.country = 'NLD' AND venue_type = 'Cinema'
GROUP BY tblfilm.title, tblprogramme.programme_date, tblfilm.country, tblvenue.venue_type, tblvenue.name
limit 500;

CREATE TABLE newfilm_1911_1920
AS
select programme_date, country, title, venue_type
FROM tblvenue, tblfilm
JOIN tblprogrammeitem ON tblprogrammeitem.film_id::text = tblfilm.film_id::text
JOIN tblprogramme ON tblprogramme.programme_id::text = tblprogrammeitem.programme_id::text
WHERE tblprogramme.programme_date >= '1900-01-01 00:00:00' AND tblprogramme.programme_date <= '1910-01-01 00:00:00' AND tblfilm.country = 'NLD' AND venue_type = 'Cinema'
GROUP BY tblfilm.title, tblprogramme.programme_date, tblfilm.country, tblvenue.venue_type
limit 500;

CREATE TABLE newfilm_1921_1930
AS
select programme_date, country, title, venue_type
FROM tblvenue, tblfilm
JOIN tblprogrammeitem ON tblprogrammeitem.film_id::text = tblfilm.film_id::text
JOIN tblprogramme ON tblprogramme.programme_id::text = tblprogrammeitem.programme_id::text
WHERE tblprogramme.programme_date >= '1900-01-01 00:00:00' AND tblprogramme.programme_date <= '1910-01-01 00:00:00' AND tblfilm.country = 'NLD' AND venue_type = 'Cinema'
GROUP BY tblfilm.title, tblprogramme.programme_date, tblfilm.country, tblvenue.venue_type
limit 500;

----Question 2 The organizers of the festival are considering to re-enact 
--such a performance and are interested to see which performances were 
--organized between 1931 and 1940. Provide a list of live performances in cinemas in the Netherlands.
select live_performance, film_year, country, tblvenue.name
From tblprogrammeitem,tblfilm, tblvenue
where film_year BETWEEN 1920 AND 1930 AND country = 'NLD' limit 1000;

CREATE TABLE live_performance1931_1940
AS
select programme_date, country, title, venue_type, live_performance
FROM tblvenue, tblfilm
JOIN tblprogrammeitem ON tblprogrammeitem.film_id::text = tblfilm.film_id::text
JOIN tblprogramme ON tblprogramme.programme_id::text = tblprogrammeitem.programme_id::text
WHERE tblprogramme.programme_date >= '1931-01-01 00:00:00' AND tblprogramme.programme_date <= '1940-01-01 00:00:00' AND tblfilm.country = 'NLD' AND venue_type = 'Cinema'
GROUP BY tblfilm.title, tblprogramme.programme_date, tblprogrammeitem.live_performance, tblfilm.country, tblvenue.venue_type
limit 500;

----Question 3 and 4

--Question 3 all the years combined
CREATE TABLE Cinemafilm_1900sto1930s
AS
SELECT tblfilm.title, tblprogramme.programme_date, tblfilm.country, tblvenue.venue_type--, --tbllocation.location_id
From tblfilm, tblprogramme, tblvenue--, --tbllocation
WHERE tblprogramme.programme_date >= '1900-01-01 00:00:00' AND tblprogramme.programme_date <= '1930-01-01 00:00:00' AND venue_type = 'Cinema' AND tblfilm.country = 'NLD'
limit 8000;

----Question 4 seperated years for the 4 spearated maps for amsterdam and also for current (5 maps)
CREATE TABLE Cinemafilm_1900s
AS
SELECT tblfilm.title, tblprogramme.programme_date, tblfilm.country, tblvenue.venue_type--, --tbllocation.location_id
From tblfilm, tblprogramme, tblvenue--, --tbllocation
WHERE tblprogramme.programme_date >= '1900-01-01 00:00:00' AND tblprogramme.programme_date <= '1910-12-31 00:00:00' AND venue_type = 'Cinema' AND tblfilm.country = 'NLD'
limit 8000;

CREATE TABLE Cinemafilm_1910s
AS
SELECT tblfilm.title, tblprogramme.programme_date, tblfilm.country, tblvenue.venue_type--, --tbllocation.location_id
From tblfilm, tblprogramme, tblvenue--, --tbllocation
WHERE tblprogramme.programme_date >= '1911-01-01 00:00:00' AND tblprogramme.programme_date <= '1920-12-31 00:00:00' AND venue_type = 'Cinema' AND tblfilm.country = 'NLD'
limit 8000;

CREATE TABLE Cinemafilm_1920s
AS
SELECT tblfilm.title, tblprogramme.programme_date, tblfilm.country, tblvenue.venue_type--, --tbllocation.location_id
From tblfilm, tblprogramme, tblvenue--, --tbllocation
WHERE tblprogramme.programme_date >= '1921-01-01 00:00:00' AND tblprogramme.programme_date <= '1930-12-31 00:00:00' AND venue_type = 'Cinema' AND tblfilm.country = 'NLD'
limit 8000;

CREATE TABLE Cinemafilm_1930s
AS
SELECT tblfilm.title, tblprogramme.programme_date, tblfilm.country, tblvenue.venue_type--, --tbllocation.location_id
From tblfilm, tblprogramme, tblvenue--, --tbllocation
WHERE tblprogramme.programme_date >= '1930-01-01 00:00:00' AND tblprogramme.programme_date <= '1940-12-31 00:00:00' AND venue_type = 'Cinema' AND tblfilm.country = 'NLD'
limit 8000;


---Question 4 adding municiaplity,location and showing the changes 1900, 1910, 1920, 1930 and current year


SELECT AddGeometryColumn('','tbllocation','geom',4326,'POINT',2);

UPDATE tbllocation
SET geom = ST_GeometryFromText('POINT(' || geodata_X
 || ' ' || geodata_Y
 || ')',4326);

SELECT AddGeometryColumn('','municipalities','geom',4326,'POINT',2);

UPDATE municipalities
SET geom = tbllocation.geom
FROM tbllocation
WHERE municipalities = tbllocation;

SELECT AddGeometryColumn('','cinemafilm_1900s','geom',4326,'POINT',2);

UPDATE Cinemafilm_1900s
SET geom = tbllocation.geom
FROM tbllocation
WHERE Cinemafilm_1900s.geom = tbllocation.geom

SELECT *
FROM municipalities
WHERE ST_Contains(municipalities.geom, tbllocation.geom)
AND municipalities.id = <your_polygon_id>;

--SELECT *
--FROM my_points
--WHERE ST_Contains(my_polygons.geom, my_points.geom)
--AND my_polygons.id = <your_polygon_id>;

SELECT f.geom
FROM municipalities AS f, Cinemafilm_1930s AS i
WHERE  i.venue_type = 'Cinema' AND ST_WITHIN(f.geom,i.geom);

---Now trying this option
CREATE TABLE amsterdam_cinemas1930 WITH OIDS
AS
--CREATE VIEW amsterdam_cinemas1930
--AS
SELECT f.id,f.gemeentena,f.geom
FROM municipalities AS f, Cinemafilm_1930s AS i
WHERE i.venue_type = 'Cinema'
AND ST_WITHIN(f.geom,i.geom);

---Question 5 number and location of cinemas per municipality for 4 decades( 1900s 19010, 1920, 1930s and even also for today)
--- this still has to do with the question 3 and 4 join and count them (tblvenue, tbllllocation, gemeentena)

---Question 6 list of cinemas that existed (or still exist) in Amsterdam between 1900 and 1940 
----including the number of different films that they showed during that period.

CREATE TABLE cinemas_thatexisted
AS
select programme_date, country, title, tblvenue.name, venue_type
FROM tblvenue, tblfilm
JOIN tblprogrammeitem ON tblprogrammeitem.film_id::text = tblfilm.film_id::text
JOIN tblprogramme ON tblprogramme.programme_id::text = tblprogrammeitem.programme_id::text
WHERE tblprogramme.programme_date >= '1900-01-01 00:00:00' AND tblprogramme.programme_date <= '2020-01-01 00:00:00' AND tblfilm.country = 'NLD' AND venue_type = 'Cinema'
GROUP BY tblfilm.title, tblprogramme.programme_date, tblvenue.name, tblvenue.venue_type, tblfilm.country, tblvenue.name
limit 50;

-----Question 7
--They are interested in locations in Amsterdam that are still in use as a cinema 
--which showed films in which Charlie Chaplin performed.

select live_performance, programme_date, country, tblvenue.name, tblfilm.info
From tblprogrammeitem,tblfilm, tblvenue, tblprogramme
WHERE tblprogramme.programme_date >= '1900-01-01 00:00:00' AND tblprogramme.programme_date <= '1980-01-01 00:00:00' AND tblfilm.country = 'NLD' AND venue_type = 'Cinema' AND tblfilm.info = 'Charlie Chaplin'
limit 1000;

select programme_date, country, tblvenue.name, tblfilm.info
FROM tblvenue, tblfilm
JOIN tblprogrammeitem ON tblprogrammeitem.film_id::text = tblfilm.film_id::text
JOIN tblprogramme ON tblprogramme.programme_id::text = tblprogrammeitem.programme_id::text
WHERE tblprogramme.programme_date >= '1900-01-01 00:00:00' AND tblprogramme.programme_date <= '2020-01-01 00:00:00' AND tblfilm.country = 'NLD' AND venue_type = 'Cinema' AND tblfilm.info = 'Charlie Chaplin'
GROUP BY tblfilm.title, tblprogramme.programme_date, tblvenue.name, tblvenue.venue_type, tblfilm.country, tblvenue.name, Tblfilm.info
limit 1000;

