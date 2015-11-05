-- Load the state, county, mcd, place and zip
RUN /vol/automed/data/uscensus1990/load_tables.pig

-- Produce state_name, city, population where city and populations
-- are 5 largest cities by population for state_name. Results 
-- ordered by state name and then population descending.

-- Reduce tables to required columns.

less_places = 
  FOREACH place
  GENERATE state_code,
           name, type,
           population;

less_state = 
  FOREACH state
  GENERATE code, name;


-- Filter out the cities.
cities = 
  FILTER less_places
  BY type == 'city';

-- Group cities by state, order entries and select top 5.
state_cities = 
  GROUP cities
  BY state_code;


top_state_cities = 
  FOREACH state_cities {
    ordered = 
      ORDER cities
      BY population DESC;
    top_5 = 
      LIMIT ordered 5;
    GENERATE FLATTEN(top_5);
  }


-- Join with state, project desired columns and order results.
state_with_cities = 
  JOIN less_state BY code,
       top_state_cities BY state_code;

less_state_with_cities = 
  FOREACH state_with_cities
  GENERATE less_state::name AS state_name,
           top_state_cities::top_5::name AS city,
           top_state_cities::top_5::population AS population;

result = 
  ORDER less_state_with_cities
  BY state_name, population DESC;

STORE result INTO 'q4' USING PigStorage(',');
