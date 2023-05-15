INSERT INTO film_1900_1910
SELECT tblfilm.title,tblprogramme.programme_date
from tblfilm,tblprogramme
limit 500;


CREATE TABLE Cinemafilm_1900sto1930s
AS
SELECT tblfilm.title, tblprogramme.programme_date, tblfilm.country, tblvenue.venue_type--, --tbllocation.location_id
From tblfilm, tblprogramme, tblvenue--, --tbllocation
WHERE tblprogramme.programme_date >= '1900-01-01 00:00:00' AND tblprogramme.programme_date <= '1930-01-01 00:00:00' AND venue_type = 'Cinema' AND tblfilm.country = 'NLD'
limit 8000;


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

select title, programme_date, country, venue_type
from cinemafilm_1930s
INNER JOIN tblfilm ON tblfilm.country = tbllocation.country
where film_year BETWEEN 1931 AND 1940 AND country = 'NLD'



SELECT AddGeometryColumn('','cinemafilm_1930s','geom',4326,'POINT',2);

UPDATE Cinemafilm_1930s
SET geom = ST_GeometryFromText('POINT(' || geodata_X
 || ' ' || geodata_Y
 || ')',4326);

SELECT AddGeometryColumn('','municipalities','geom1',4326,'POINT',2);

UPDATE Cinemafilm_1930s
SET geom = tbllocation.geom
FROM tbllocation
WHERE Cinemafilm_1930s.geom = tbllocation.geom
