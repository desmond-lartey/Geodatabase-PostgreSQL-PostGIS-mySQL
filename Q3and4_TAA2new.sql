
---Question 1
SELECT tblfilm.title,tblprogramme.programme_date
from tblfilm,tblprogramme
limit 500;

CREATE TABLE newfilm_1900_1910
AS
select programme_date, country, title, venue_type
FROM tblvenue, tblfilm
JOIN tblprogrammeitem ON tblprogrammeitem.film_id::text = tblfilm.film_id::text
JOIN tblprogramme ON tblprogramme.programme_id::text = tblprogrammeitem.programme_id::text
WHERE tblprogramme.programme_date >= '1900-01-01 00:00:00' AND tblprogramme.programme_date <= '1910-01-01 00:00:00' AND tblfilm.country = 'NLD' AND venue_type = 'Cinema'
GROUP BY tblfilm.title, tblprogramme.programme_date, tblfilm.country, tblvenue.venue_type
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

----Question 2
select live_performance, film_year, country  
From tblprogrammeitem,tblfilm 
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

