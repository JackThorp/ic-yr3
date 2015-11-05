-- Produce CSV of state_name, no_city, no_town, no_village
-- from place table - no results for states with no place 
-- records. Order by state_name.

-- Load the state, county, mcd, place and zip
RUN /vol/automed/data/uscensus1990/load_tables.pig;

-- Reduce data to required columns.
less_places = 
  FOREACH place
  GENERATE state_code, type;

less_state = 
  FOREACH state
  GENERATE name, code;


-- Group by state code and calculate per group/bag aggregates.
places_by_state = 
  GROUP less_places
  BY state_code;

places_by_state_agg = 
  FOREACH places_by_state {
    towns = 
      FILTER less_places
      BY type == 'town';
    villages = 
      FILTER less_places
      BY type == 'village';
    cities = 
      FILTER less_places
      BY type == 'city';
    GENERATE group AS state_code,
             COUNT(towns) AS no_town,
             COUNT(villages) AS no_village,
             COUNT(cities) AS no_city;
  }


-- Join with 'state'.
state_with_places = 
  JOIN less_state BY code,
       places_by_state_agg BY state_code;


-- Project desired columns and order result.
less_state_and_places = 
  FOREACH state_with_places
  GENERATE less_state::name AS state_name,
           places_by_state_agg::no_town AS no_town,
           places_by_state_agg::no_village AS no_village,
           places_by_state_agg::no_city AS no_city;

result = 
  ORDER less_state_and_places
  BY state_name;

STORE result INTO 'q3' USING PigStorage(',');
