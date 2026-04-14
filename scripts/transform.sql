-- Handle foreign characters
-- In the SQL schema, convert the datatype of the 'title' column from varchar to nvarchar to accomodate foreign language characters

-- Remove duplicates
-- Check for duplicate values
select *
from netflix_raw
where concat(title, type) in (
select concat(title, type)
from netflix_raw
group by title, type
having count(*) > 1)
order by title;

-- Drop duplicates
with title_rn as (
select show_id, type, title, director, cast, country, date_added, release_year, rating, duration, listed_in, description, 
row_number() over(partition by title, type order by show_id) as rn
from netflix_raw
)
select show_id, type, title,  date_added, release_year, rating, duration, description
from title_rn
where rn = 1;

-- New table for listed_in/genre, director, country, and cast
-- Netflix genre table
select show_id, trim(value) as genre
into netflix_genre
from netflix_raw
cross apply string_split(listed_in, ',');

-- Netflix directors table
select show_id, trim(value) as director
into netflix_directors
from netflix_raw
cross apply string_split(director, ',');

-- Netflix country table
select show_id, trim(value) as country
into netflix_country
from netflix_raw
cross apply string_split(country, ',');

-- Netflix cast table
select show_id, trim(value) as cast
into netflix_cast
from netflix_raw
cross apply string_split(cast, ',');

-- Data type conversion for date_added (varchar -> date)
with title_rn as (
select show_id, type, title, director, cast, country, date_added, release_year, rating, duration, listed_in, description, 
row_number() over(partition by title, type order by show_id) as rn
from netflix_raw
)
select show_id, type, title,  cast(date_added as date) as date_added, release_year, rating, duration, description
from title_rn
where rn = 1;

-- Identify and populate missing values in the country and duration columns
-- Country Column:
-- Assumption: If a director is mapped to multiple countries, it is assumed that the movie/tv show is released in all the mapped countries
insert into netflix_country
with cte_mapping as (
select distinct nd.director, nc.country
from netflix_country as nc
inner join netflix_directors as nd 
on nc.show_id = nd.show_id
)
select show_id, cm.country
from netflix_raw as nr 
inner join cte_mapping as cm 
on nr.director = cm.director
where nr.country is null;

-- Duration Column:
-- Note: Some columns have duration value in the rating column
with title_rn as (
select show_id, type, title, director, cast, country, date_added, release_year, rating, duration, listed_in, description, 
row_number() over(partition by title, type order by show_id) as rn
from netflix_raw
)
select show_id, type, title,  cast(date_added as date) as date_added, release_year, rating, 
case when duration is null then rating else duration end as duration, description
into netflix_stg
from title_rn
where rn = 1;