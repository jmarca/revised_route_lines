-- Deploy revised_route_lines:initial_routelines to pg
-- requires: tempseg_schema
-- requires: rdg

BEGIN;

WITH anydir as (
   select distinct relation_id,direction
   from tempseg.relation_direction_geometries d
   where direction != 'any'
),
nother_table as (
   select rdg.relation_id
         ,rdg.sequence_id
         ,rdg.linestring
         ,rdg.ordering,b.direction
   from tempseg.relation_direction_geometries rdg
   join anydir b on (b.relation_id=rdg.relation_id)
   where rdg.direction='any'
),
rsg_and_nother as (
   select rdg.relation_id,
       rdg.direction,
       rdg.linestring,
       rdg.sequence_id
   from tempseg.relation_direction_geometries rdg
   where rdg.direction != 'any'
 UNION
   select n.relation_id,
       n.direction,
       n.linestring,
       n.sequence_id
   from nother_table n
)
select relation_id,direction
      ----  ,st_numGeometries(st_linemerge(st_collect(linestring)))
      ,st_linemerge(st_collect(linestring)) as linestring
into tempseg.initial_routelines
from rsg_and_nother
group by relation_id,direction;


--  now add the 'any' direction ones

WITH anydir as (
   select distinct relation_id,direction
   from tempseg.relation_direction_geometries d
   where direction != 'any'
),
nother_table as (
   select rdg.relation_id
         ,rdg.sequence_id
         ,rdg.linestring
         ,rdg.ordering,b.direction
   from tempseg.relation_direction_geometries rdg
   join anydir b on (b.relation_id=rdg.relation_id)
   where rdg.direction='any'
),
uniq_nother as (
   select distinct relation_id from nother_table
),
rsg_and_nother as (
   select rdg.relation_id,
       rdg.direction,
       rdg.linestring,
       rdg.sequence_id
   from tempseg.relation_direction_geometries rdg
   left outer join uniq_nother n using (relation_id)
   where rdg.direction = 'any' and
         n.relation_id is null
)
INSERT INTO tempseg.initial_routelines
SELECT relation_id, 'both' as direction
 --,st_numGeometries(st_linemerge(st_collect(linestring)))
 ,st_linemerge(st_collect(linestring))
 as linestring
from rsg_and_nother
group by relation_id, direction;

COMMIT;

 -- 400 rows then 258 rows for 658 total
