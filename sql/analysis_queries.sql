--1. For each director, count the number of movies and TV shows created by them in separate columns for directors who have created TV shows and movies both.
select nd.director, 
count(distinct case when ns.type = 'Movie' then ns.show_id else null end) as movies_cnt, 
count(distinct case when ns.type = 'TV Show' then ns.show_id else null end) as tv_shows_cnt
from netflix_stg as ns
inner join netflix_directors as nd
on ns.show_id = md.show_id
group by nd.director
having count(distinct ns.type) = 2

--2. Which country has highest number of comedy movies? 
with cte_country_rnk as (
select nc.country, rank() over(order by count(distinct ng.show_id) desc) as country_rnk
from netflix_genre as ng
inner join netflix_country as nc on ng.show_id = nc.show_id
inner join netflix_stg as ns on ng.show_id = ns.show_id
where ng.genre = 'Comedies'
and ns.type = 'Movie'
group by nc.country
)
select country
from cte_country_rnk
where country_rnk = 1

--3. For each year (as per date_added to Netflix), which director has maximum number of movies released?
with cte_movies as (
select nd.director, year(ns.date_added) as date_year, count(ns.show_id) as movies_cnt
from netflix_stg as ns
inner join netflix_directors as nd on ns.show_id = nd.show_id
where ns.type = 'Movie'
group by nd.director, year(ns.date_added)
), cte_movies_cnt_rnk as (
select director, date_year, movies_cnt, rank() over(partition by date_year order by movies_cnt desc) as movies_cnt_rnk
from cte_movies
)
select director, date_year, movies_cnt
from cte_movies_cnt_rnk
where movies_cnt_rnk = 1

--4. What is average duration of movies in each genre?
select ng.genre, avg(cast(replace(ns.duration, ' min') as int)) as avg_duration
from netflix_genre as ng
inner join netflix_stg as ns on ng.show_id = ns.show_id
where ns.type = 'Movie'
group by ng.genre

--5. Find the list of directors who have created both horror and comedy movies. Display director names along with number of comedy and horror movies directed by them. 
select nd.director, 
count(distinct case when ng.genre = 'Comedies' then ns.show_id else null end) as comedy_movies_cnt,
count(distinct case when ng.genre = 'Horror Movies' then ns.show_id else null end) as horror_movies_cnt
from netflix_genre as ng
inner join netflix_stg as ns on ng.show_id = ns.show_id
inner join netflix_directors as nd on nd.show_id = ns.show_id
where ns.type = 'Movie'
and ng.genre in ('Comedies', 'Horror Movies')
group by nd.director
having count(distinct ng.genre) = 2