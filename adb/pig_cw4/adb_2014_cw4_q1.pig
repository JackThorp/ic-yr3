-- Load the state, county, mcd, place and zip
RUN /vol/automed/data/uscensus1990/load_tables.pig; 

-- reduce two tables to required columns.
less_state = 
  FOREACH state
  GENERATE name, code;

less_county = 
  FOREACH county
  GENERATE state_code;

-- left join and eliminate null matches
state_and_county = 
  JOIN less_state BY code LEFT,
       less_county BY state_code;

state_with_county = 
  FILTER state_and_county
  BY less_county::state_code IS NULL;

-- project desired columns, remove duplicates and order.
state_names = 
  FOREACH state_with_county
  GENERATE less_state::name AS state_name;

distinct_state_names = 
  DISTINCT state_names;

result = 
  ORDER distinct_state_names
  BY state_name;

STORE result INTO 'q1' USING PigStorage(',');
