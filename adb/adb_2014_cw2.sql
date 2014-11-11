
---- Q1 ----
SELECT  state.name AS state_name, place.name
FROM    place JOIN state ON place.state_code = state.code
WHERE   place.name LIKE '%City'
AND     place.type != 'city';
--(250 rows)--

---- Q2 ----
SELECT  state.name AS state_name,
        COUNT(place.type) AS no_big_city,
        SUM(place.population) AS big_city_population
FROM    state JOIN place ON
        state.code = place.state_code
WHERE   place.type = 'city'
AND     place.population >= 100000
GROUP BY state.name
HAVING  COUNT(place.type) >= 5
OR      SUM(place.population) >= 1000000;
--(15 rows)--

---- Q3 ----
WITH  county_types(type, county) AS
      (
       SELECT type, COUNT(type) AS county 
       FROM county 
       GROUP BY type
      ),
      place_types(type, place) AS
      (
       SELECT type, COUNT(type) AS place 
       FROM place
       GROUP BY type
      ),
      mcd_types(type, mcd) AS
      (
       SELECT type, COUNT(type) AS mcd
       FROM mcd 
       GROUP BY  type
      )
SELECT  type,
        COALESCE (county, 0),
        COALESCE (place,  0),
        COALESCE (mcd,    0)
FROM  county_types 
      FULL OUTER JOIN
      place_types 
      USING (type)
      FULL OUTER JOIN
      mcd_types 
      USING (type)
WHERE type IS NOT NULL;
--(27 rows)--

---- Q4 ----
WITH  totals (total_population, total_land_area) AS
      (
       SELECT SUM(population) AS total_population,
              SUM(land_area) AS total_land_area
       FROM mcd
      )
SELECT  state.name,
        SUM (population) AS population,
        ROUND (100*SUM (mcd.population) / totals.total_population, 2) AS pc_population,
        SUM (land_area) AS land_area,
        ROUND (100*SUM (mcd.land_area) / totals.total_land_area, 2) AS pc_land_area
FROM    (state LEFT JOIN mcd ON state.code = mcd.state_code),
        totals
GROUP BY state.name,
         totals.total_population,
         totals.total_land_area
ORDER BY name;
--(57 rows)--

---- Q5 -----
SELECT  ranked_counties.state_name,
        ranked_counties.county_name,
        ranked_counties.population
FROM    (SELECT state.name AS state_name,
                county.name AS county_name,
                county.population AS population,
                RANK() OVER 
                (
                  PARTITION BY state.code
                  ORDER BY county.population DESC
                ) AS rank
         FROM state JOIN county 
         ON state.code = county.state_code) AS ranked_counties
WHERE rank <= 5;
--(249 rows)--

---- Q6 -----
/*
CREATE FUNCTION get_distance(real, real, real, real) RETURNS real AS $$
    SELECT  ACOS(  SIN($1*PI()/180)*SIN($3*PI()/180) + 
                  COS($1*PI()/180)*COS($3*PI()/180) *
                  COS($4*PI()/180-$2*PI()/180) 
                ) * 3591;
$$ LANGUAGE SQL;

SELECT get_distance(51.498893,-0.184944,51.578171,-0.030363) as distance;
*/
/*
    Couldn't create a function because I believe I lack privilleges. I tried to improve
    the efficiency of this table by reducing both tables before the cross join.
*/
SELECT  less_zip.zip_code,
        less_zip.zip_name,
        less_place.name,
        (ACOS(SIN(less_place.latitude*PI()/180)*SIN(less_zip.latitude*PI()/180) +
              COS(less_place.latitude*PI()/180)*COS(less_zip.latitude*PI()/180) * 
              COS(less_zip.longitude*PI()/180-less_place.longitude*PI()/180) ) *  3959) AS distance

FROM    (SELECT place.name, place.latitude, place.longitude
         FROM   place
         WHERE  place.state_code = 6) AS less_place 
        CROSS JOIN
        (SELECT zip.zip_code, zip.zip_name, zip.latitude, zip.longitude
         FROM   zip
         WHERE  zip.state_code = 6) AS less_zip
WHERE   ACOS(SIN(less_place.latitude*PI()/180)*SIN(less_zip.latitude*PI()/180) +
            COS(less_place.latitude*PI()/180)*COS(less_zip.latitude*PI()/180) * 
            COS(less_zip.longitude*PI()/180-less_place.longitude*PI()/180) ) * 3959 <= 5
ORDER BY less_zip.zip_code;
--(4331 rows)--
