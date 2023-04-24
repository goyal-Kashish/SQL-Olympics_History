select * from athlete_events
select * from athletes

-- Ques 1: Which team has won the maximum gold medals over the years.

  select top 1 team, count(*) as No_of_medals_won from
  (select A.athlete_id, B.team, A.medal from athlete_events A
  inner join athletes B on A.athlete_id=B.id
  where A.medal='Gold') X
  group by team
  order by No_of_medals_won desc

/* Ques 2: For each team print total silver medals and year in which they won maximum silver medal..
           output 3 columns: team,total_silver_medals, year_of_max_silver */

  with cte1 as
  (select team, count(*) as total_silver_medals from
  (select A.athlete_id, B.team, A.medal from athlete_events A
  inner join athletes B on A.athlete_id=B.id
  where A.medal='Silver') X
  group by team
  )

 , cte2 as
  (select team, year, count(*) as No_of_silver_medals from
  (select A.athlete_id, B.team, A.year, A.medal from athlete_events A
  inner join athletes B on A.athlete_id=B.id
  where A.medal='Silver') X
  group by team, year 
  --order by team, year
  )
  
 , cte3 as
 (select team, string_agg(year,';') as year_of_max_silver from
 (select cte2.*, B.maxi from cte2
 inner join 
  (select team, max(No_of_silver_medals) as maxi from cte2 group by team) B
  on cte2.team=B.team and cte2.No_of_silver_medals=B.maxi) X
  group by team
  )

  select cte3.team, total_silver_medals, year_of_max_silver
  from cte1 inner join cte3
  on cte1.team=cte3.team

/*Ques 3: Which player has won maximum gold medals amongst the players which 
          have won only gold medal (never won silver or bronze) over the years */

  
  with cte1 as
  (select B.id, B.name, A.medal from athlete_events A 
  inner join athletes B on A.athlete_id=B.id
  where A.medal !='NA'
  )
  , cte2 as
  (select id, name, count(distinct medal) as count from
  cte1
  group by id, name
  having count(distinct medal)=1
  )
   
  select  top 1 id, name, count(medal) as gold_medals_won from
  (select cte1.*, cte2.count from cte1 inner join cte2 on cte1.id=cte2.id
  where cte1.medal='Gold') A
  group by id,name
  order by gold_medals_won desc

 /* Ques 4: In each year which player has won maximum gold medal . Write a query to print year,player name 
         and no of golds won in that year . In case of a tie print comma separated player names. */

   
   with cte1 as
   (select name, year, count(*) as count from
   (select B.id, B.name, A.year, A.medal from athlete_events A inner join athletes B
   on A.athlete_id=B.id
   where A.medal='Gold') A
   group by name,year
   --order by year
   )

   , cte2 as
   (select cte1.*, A.maximum from
   (select year, max(count) as maximum from cte1 group by year) A
   inner join
   cte1 on cte1.year=A.year
   where count=maximum
   )

   select A.*, B.count as gold_medals_won from
   (select year, string_agg(name, ' ; ') player_name from 
   cte2
   group by year) A
   inner join
   (select year, count from cte2 group by year, count) B
   on A.year=B.year
   

/* Ques 5: In which event and year India has won its first gold medal,first silver medal and first bronze medal
           print 3 columns medal,year,sport */

   
   with cte1 as
   (
   select distinct * from
   (select A.medal, A.year, A.event, B.team from athlete_events A
   inner join athletes B on A.athlete_id=B.id
   where team='India' and medal!='NA') A
   )

   select B.medal, cte1.year, event from cte1
   inner join 
   (select medal, min(year) as minimum from cte1 group by medal) B
   on cte1.year=B.minimum


-- Ques 6: Find players who won gold medal in summer and winter olympics both.
  
  select name, count(distinct season) as count from
  (select athlete_id, season, medal,name from athlete_events ae inner join 
  athletes a on ae.athlete_id=a.id
  where medal='Gold') A
  group by name
  having count(distinct season)=2


-- Ques 7: Find players who won gold, silver and bronze medal in a single olympics. print player name along with year.


  select name, year from
  (select name, year, count(distinct medal) as count from
  (select id, name, year, medal from athlete_events ae 
  inner join athletes a on ae.athlete_id=a.id
  where medal!='NA') A
  group by name, year) B
  where count=3


/* Ques 8: Find players who have won gold medals in consecutive 3 summer olympics in the same event . Consider only olympics 2000 onwards. 
           Assume summer olympics happens every 4 year starting 2000. print player name and event name. */

  
  with cte1 as
  (select name, year, season, event from athlete_events ae
  inner join athletes a on ae.athlete_id=a.id
  where medal='Gold' and year>=2000 and season='Summer') 

  select * from
  (select *, lead(year,1) over(partition by name,event order by year) as next_year,
  lag(year,1) over(partition by name,event order by year) as prev_year 
  from cte1) A
  where year=prev_year+4 and year=next_year-4
