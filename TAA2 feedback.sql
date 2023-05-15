
---Question 1 organizers want to have three lists of films that were in Dutch cinemas 
--between 1900- 1910, 1911-1920 and 1921-1930  as inspiration for their festival program.
--#Creates a list of films and their programme date to have a fair idea
--# of what films are shown within certain dates

--#then create a table to contain all the years you want.
--#Now group the result of the first query by film title and programme date
--#repeat and adjust steps for all the listed years
CREATE TABLE newfilm_1900_1910
AS
select title, programme_date
FROM tblfilm
JOIN tblprogrammeitem ON tblprogrammeitem.film_id::text = tblfilm.film_id::text
JOIN tblprogramme ON tblprogramme.programme_id::text = tblprogrammeitem.programme_id::text
WHERE programme_date >= '1900-01-01 00:00:00' AND tblprogramme.programme_date <= '1910-01-01 00:00:00'
GROUP BY tblfilm.title, programme_date
limit 10;


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
--#You will first identify what tbale contains programs or films that aso included 
--# live performance. 
select live_performance, film_year, country, tblvenue.name
From tblprogrammeitem,tblfilm, tblvenue
where film_year BETWEEN 1920 AND 1930 AND country = 'NLD' limit 1000;

--#then only create the list of programms with live performance and what movies
--# were shown
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
--#First create a list of all the years combined and inspect the
--#output table
--Question 3 all the years combined
CREATE TABLE Cinemafilm_1900sto1930s
AS
SELECT tblfilm.title, tblprogramme.programme_date, tblfilm.country, tblvenue.venue_type--, --tbllocation.location_id
From tblfilm, tblprogramme, tblvenue--, --tbllocation
WHERE tblprogramme.programme_date >= '1900-01-01 00:00:00' AND tblprogramme.programme_date <= '1930-01-01 00:00:00' AND venue_type = 'Cinema' AND tblfilm.country = 'NLD'
limit 8000;


----Question 4 seperated years for the 4 spearated maps for amsterdam and also for current (5 maps)
--#Now sparate the years as requested by adjusting the programme date
--#The information request is tailored for only cinemas, so include a constraint
--#for the venue type attribute in the tblvenue. Create query for first year
--#and repeat for other years
CREATE TABLE Cinemafilm_1900s
AS
SELECT tblfilm.title, tblprogramme.programme_date, tblfilm.country, tblvenue.venue_type, tblvenue.name--, --tbllocation.location_id
From tblfilm, tblprogramme, tblvenue--, --tbllocation
WHERE tblprogramme.programme_date >= '1900-01-01 00:00:00' AND tblprogramme.programme_date <= '1910-12-31 00:00:00' AND venue_type = 'Cinema' AND tblfilm.country = 'NLD'
limit 8000;

--#Because the request includes a display of the location of the cinemas for
--entire country and for Amsterdam only, include the geometry
--First convert shp to sql with shp2sql.exe
---For all cinemas in 1900s and in Amsterdam
CREATE TABLE Cinemafilm_1900s11
AS
SELECT tbllocation.geom, tblvenue.name, tblvenueactiveperiode.date_opened
FROM tblvenue
INNER JOIN tblvenueactiveperiode ON tblvenueactiveperiode.venue_id = tblvenue.venue_id
INNER JOIN tbllocation ON tbllocation.location_id = tblvenue.location_id
WHERE tblvenueactiveperiode.date_opened  >= '1/1/1900 0:00' AND tblvenueactiveperiode.date_opened <= '12/31/1910 0:00';


---This didn't work
SELECT cinemafilm_1900s11.geom, municipalities.geom
FROM cinemafilm_1900s11, municipalities
WHERE ST_Contains(municipalities.geom, cinemafilm_1900s11.geom)
AND municipalities.geom = cinemafilm_1900s11.geom  AND municipalities.gemeentena = 'Amsterdam';

--This will answer only for Amsterdam- location of cinemas in amsterdam in 1900s
---try to find a way to add what name of the locations, cinema and what movies were shown

--#for every results output for the entire country, use a spatial join ST_WITHIN
--#to set a constraint for locations of cinema for the entire country that is only 
--#within the boundaries of the municipality of Amsterdam
CREATE TABLE cinemafilm_1900sams
AS
SELECT f.geom
FROM cinemafilm_1900s11 AS f, municipalities AS i
WHERE  i.gemeentena = 'Amsterdam' AND ST_WITHIN(f.geom,i.geom);

--SELECT *
--FROM my_points
--WHERE ST_Contains(my_polygons.geom, my_points.geom)
--AND my_polygons.id = <your_polygon_id>;

---For all cinemas in 1910s and in Amsterdam
CREATE TABLE Cinemafilm_1910s
AS
SELECT tblfilm.title, tblprogramme.programme_date, tblfilm.country, tblvenue.venue_type--, --tbllocation.location_id
From tblfilm, tblprogramme, tblvenue--, --tbllocation
WHERE tblprogramme.programme_date >= '1911-01-01 00:00:00' AND tblprogramme.programme_date <= '1920-12-31 00:00:00' AND venue_type = 'Cinema' AND tblfilm.country = 'NLD'
limit 8000;

CREATE TABLE Cinemafilm_1910s11
AS
SELECT tbllocation.geom, tblvenue.name, tblvenueactiveperiode.date_opened
FROM tblvenue
INNER JOIN tblvenueactiveperiode ON tblvenueactiveperiode.venue_id = tblvenue.venue_id
INNER JOIN tbllocation ON tbllocation.location_id = tblvenue.location_id
WHERE tblvenueactiveperiode.date_opened  >= '1/1/1911 0:00' AND tblvenueactiveperiode.date_opened <= '12/31/1920 0:00';

CREATE TABLE cinemafilm_1910sams
AS
SELECT f.geom
FROM cinemafilm_1910s11 AS f, municipalities AS i
WHERE  i.gemeentena = 'Amsterdam' AND ST_WITHIN(f.geom,i.geom);

---For all cinemas in 1920s and in Amsterdam
CREATE TABLE Cinemafilm_1920s
AS
SELECT tblfilm.title, tblprogramme.programme_date, tblfilm.country, tblvenue.venue_type--, --tbllocation.location_id
From tblfilm, tblprogramme, tblvenue--, --tbllocation
WHERE tblprogramme.programme_date >= '1921-01-01 00:00:00' AND tblprogramme.programme_date <= '1930-12-31 00:00:00' AND venue_type = 'Cinema' AND tblfilm.country = 'NLD'
limit 8000;

CREATE TABLE Cinemafilm_1920s11
AS
SELECT tbllocation.geom, tblvenue.name, tblvenueactiveperiode.date_opened
FROM tblvenue
INNER JOIN tblvenueactiveperiode ON tblvenueactiveperiode.venue_id = tblvenue.venue_id
INNER JOIN tbllocation ON tbllocation.location_id = tblvenue.location_id
WHERE tblvenueactiveperiode.date_opened  >= '1/1/1921 0:00' AND tblvenueactiveperiode.date_opened <= '12/31/1930 0:00';

CREATE TABLE cinemafilm_1920sams
AS
SELECT f.geom
FROM cinemafilm_1920s11 AS f, municipalities AS i
WHERE  i.gemeentena = 'Amsterdam' AND ST_WITHIN(f.geom,i.geom);

---For all cinemas in 1930s and in Amsterdam
CREATE TABLE Cinemafilm_1930s
AS
SELECT tblfilm.title, tblprogramme.programme_date, tblfilm.country, tblvenue.venue_type--, --tbllocation.location_id
From tblfilm, tblprogramme, tblvenue--, --tbllocation
WHERE tblprogramme.programme_date >= '1930-01-01 00:00:00' AND tblprogramme.programme_date <= '1940-12-31 00:00:00' AND venue_type = 'Cinema' AND tblfilm.country = 'NLD'
limit 8000;

CREATE TABLE Cinemafilm_1930s11
AS
SELECT tbllocation.geom, tblvenue.name, tblvenueactiveperiode.date_opened
FROM tblvenue
INNER JOIN tblvenueactiveperiode ON tblvenueactiveperiode.venue_id = tblvenue.venue_id
INNER JOIN tbllocation ON tbllocation.location_id = tblvenue.location_id
WHERE tblvenueactiveperiode.date_opened  >= '1/1/1931 0:00' AND tblvenueactiveperiode.date_opened <= '12/31/1940 0:00';

CREATE TABLE cinemafilm_1930sams
AS
SELECT f.geom
FROM cinemafilm_1930s11 AS f, municipalities AS i
WHERE  i.gemeentena = 'Amsterdam' AND ST_WITHIN(f.geom,i.geom);

-----All munucipality Today
--#The tblvenueactiveperiode also includes an attribtes of veneues which are closed and or
--#opened. The 'null' field are those that are still active or still exist today
--## We will first query this for the entire country
CREATE TABLE Cinemafilm_amstoday
AS
SELECT tbllocation.geom, tblvenue.name, tblvenueactiveperiode.date_opened
FROM tblvenue
INNER JOIN tblvenueactiveperiode ON tblvenueactiveperiode.venue_id = tblvenue.venue_id
INNER JOIN tbllocation ON tbllocation.location_id = tblvenue.location_id
WHERE tblvenueactiveperiode.date_closed  IS NULL;

----Amsterdam Today
--#We will now set the constriant of a spatial join 'ST_WITHIN' to extarct only
--locations that still exist in Amsterdam today
CREATE TABLE cinemafilm_amstodaywithin
AS
SELECT f.geom
FROM Cinemafilm_amstoday AS f, municipalities AS i
WHERE  i.gemeentena = 'Amsterdam' AND ST_WITHIN(f.geom,i.geom);

---For all cinemas after 1940s existing today and in Amsterdam

CREATE TABLE Cinemafilm_existtoday
AS
SELECT tbllocation.geom, tblvenue.name, tblvenueactiveperiode.date_opened
FROM tblvenue
INNER JOIN tblvenueactiveperiode ON tblvenueactiveperiode.venue_id = tblvenue.venue_id
INNER JOIN tbllocation ON tbllocation.location_id = tblvenue.location_id
WHERE tblvenueactiveperiode.date_opened  >= '1/1/1941 0:00' AND tblvenueactiveperiode.date_opened <= '12/31/2020 0:00';

CREATE TABLE Cinemafilm_existtoday1
AS
SELECT tbllocation.geom, tblvenue.name, tblvenueactiveperiode.date_opened
FROM municipalities, tblvenue
INNER JOIN tblvenueactiveperiode ON tblvenueactiveperiode.venue_id = tblvenue.venue_id
INNER JOIN tbllocation ON tbllocation.location_id = tblvenue.location_id
WHERE tblvenueactiveperiode.date_opened  >= '1/1/1941 0:00' AND tblvenueactiveperiode.date_opened <= '12/31/2020 0:00' AND municipalities.gemeentena = 'Amsterdam';

CREATE TABLE Cinemafilm_existtoday2
AS
SELECT tbllocation.geom, tblvenue.name, tblvenueactiveperiode.date_closed
FROM municipalities, tblvenue
INNER JOIN tblvenueactiveperiode ON tblvenueactiveperiode.venue_id = tblvenue.venue_id
INNER JOIN tbllocation ON tbllocation.location_id = tblvenue.location_id
WHERE tblvenueactiveperiode.date_closed  IS NULL;


CREATE TABLE cinemafilm_existsams
AS
SELECT f.geom
FROM Cinemafilm_existtoday AS f, municipalities AS i
WHERE  i.gemeentena = 'Amsterdam' AND ST_WITHIN(f.geom,i.geom);

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
--# With this databse, join tblprogrammeitem with tblfilm to extract the number of 
--time a certain film has been shown and their requested dates.
CREATE TABLE cinemas_thatexistedfilmshown
AS
select title, tblvenue.name, programme_date, tblvenueactiveperiode.date_closed
FROM tblvenue, tblprogramme, tblvenueactiveperiode, tblfilm
JOIN tblprogrammeitem ON tblprogrammeitem.film_id::text = tblfilm.film_id::text
WHERE tblprogramme.programme_date BETWEEN '1900-01-01 00:00:00' AND  '1940-01-01 00:00:00' 
AND tblfilm.country = 'NLD' AND venue_type = 'Cinema'
AND tblvenueactiveperiode.date_closed  IS NULL
limit 2000;

SELECT tblvenue.name, COUNT(*) AS num_films_shown
FROM tblprogrammeitem 
LEFT JOIN tblprogramme ON tblprogramme.programme_id = tblprogrammeitem.programme_id
LEFT JOIN tblvenue ON tblvenue.venue_id = tblprogramme.venue_id
LEFT outer JOIN tbllocation ON (tblvenue.location_id= tbllocation.location_id)
LEFT JOIN municipalities ON ST_Intersects(tbllocation.geom, municipalities.geom)
WHERE municipalities.gemeentena = 'Amsterdam'
  AND EXTRACT(year FROM tblprogramme.programme_date) BETWEEN 1900 AND 1909
GROUP BY tblvenue.name, tblvenue.venue_id
ORDER BY num_films_shown DESC limit 20;

-----Question 7
--They are interested in locations in Amsterdam that are still in use as a cinema 
--which showed films in which Charlie Chaplin performed.
--#Join tblprogrammeitem, tblprogramme and tblfilm. From the 'info' attributes
-- you can extract the info description where it made mention of charlie chaplin
select programme_date, tblvenue.name, tblfilm.info, tbllocation.country, venue_type
From tblprogrammeitem,tblfilm, tblvenue, tblprogramme, tbllocation
WHERE tblprogramme.programme_date >= '1941-01-01 00:00:00' AND tblprogramme.programme_date <= '2020-01-01 00:00:00' 
--AND tbllocation.country
AND "tblfilm".info ILIKE '%Charlie Chaplin%' AND venue_type= 'Cinema'
limit 1000;

select programme_date, tblvenue.name, venue_type, tblfilm.info
FROM tblvenue, tblfilm
JOIN tblprogrammeitem ON tblprogrammeitem.film_id::text = tblfilm.film_id::text
JOIN tblprogramme ON tblprogramme.programme_id::text = tblprogrammeitem.programme_id::text
WHERE tblprogramme.programme_date >= '1900-01-01 00:00:00' AND tblprogramme.programme_date <= '1980-01-01 00:00:00' 
AND "tblfilm".info LIKE '%Chaplin%' AND Venue_type = 'Cinema'
limit 1000;

WHERE "tblfilm".info  LIKE %aplin%;

ILIKE '%Chaplin%
