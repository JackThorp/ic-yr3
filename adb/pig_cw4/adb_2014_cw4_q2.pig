-- Load the state, county, mcd, place and zip
RUN /vol/automed/data/uscensus1990/load_tables.pig

-- project only required columns
less_county = 
  FOREACH county
  GENERATE state_code,
           population,
           land_area;

less_state = 
  FOREACH state
  GENERATE code, name;


-- group county records by state and calculate aggregates.
county_by_state = 
  GROUP less_county
  BY state_code;

county_aggregates = 
  FOREACH county_by_state
  GENERATE group AS state_code,
           SUM(less_county.population) AS population,
           SUM(less_county.land_area) AS land_area;


-- Join tables.
state_with_county = 
  JOIN less_state BY code,
       county_aggregates BY state_code;


-- project desired columns and order result.
state_with_county_projected = 
  FOREACH state_with_county
  GENERATE less_state::name AS state_name, 
           county_aggregates::population AS population,
           county_aggregates::land_area AS land_area;

result = 
  ORDER state_with_county_projected 
  BY state_name;

STORE result INTO 'q2' USING PigStorage(',');
