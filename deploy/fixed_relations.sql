-- Deploy revised_route_lines:fixed_relations to pg
-- requires: split_lines

-- see notes from development work in
-- ~/repos/jem/osm/sql/views/revised_routelines_work.sql

BEGIN;

-- have split lines.  fix them by gradually ratcheting the filter to
-- remove first super short segments, then long and longer ones, up to
-- 1000, whatever that is (1km I think)

-- idea is that you remove the short segments from multilinestrings,
-- hopefully making simple linestringsq.  I think anyway.

-- first, initial set

WITH
split_geo_type as (
   select GeometryType(st_linemerge(st_collect(routeline))) as geomtype,
       relation_id,direction
   from tempseg.route_relations_split_lines
   group by relation_id,direction
   order by geomtype
)
SELECT relation_id,direction
INTO tempseg.fixed_relations
from split_geo_type where geomtype = 'LINESTRING';

-- manual ratchet

-- 100

delete
from tempseg.route_relations_split_lines
where
(st_length_Spheroid(
     routeline,
     'SPHEROID["GRS_1980",6378137,298.257222101]')) < 100
;


WITH
merged_line as (
  select GeometryType(
          st_linemerge(st_collect(routeline))) as geomtype,
         relation_id,direction
  from tempseg.route_relations_split_lines
  left outer join tempseg.fixed_relations q using(relation_id,direction) where q.relation_id is null
  group by relation_id,direction
  order by geomtype
)
insert into tempseg.fixed_relations (relation_id,direction)
select relation_id,direction
from merged_line where geomtype = 'LINESTRING';

delete
from tempseg.route_relations_split_lines
where
(st_length_Spheroid(
     routeline,
     'SPHEROID["GRS_1980",6378137,298.257222101]')) < 200
;


WITH
merged_line as (
  select GeometryType(
          st_linemerge(st_collect(routeline))) as geomtype,
         relation_id,direction
  from tempseg.route_relations_split_lines
  left outer join tempseg.fixed_relations q using(relation_id,direction) where q.relation_id is null
  group by relation_id,direction
  order by geomtype
)
insert into tempseg.fixed_relations (relation_id,direction)
select relation_id,direction
from merged_line where geomtype = 'LINESTRING';

delete
from tempseg.route_relations_split_lines
where
(st_length_Spheroid(
     routeline,
     'SPHEROID["GRS_1980",6378137,298.257222101]')) < 400
;


WITH
merged_line as (
  select GeometryType(
          st_linemerge(st_collect(routeline))) as geomtype,
         relation_id,direction
  from tempseg.route_relations_split_lines
  left outer join tempseg.fixed_relations q using(relation_id,direction) where q.relation_id is null
  group by relation_id,direction
  order by geomtype
)
insert into tempseg.fixed_relations (relation_id,direction)
select relation_id,direction
from merged_line where geomtype = 'LINESTRING';

delete
from tempseg.route_relations_split_lines
where
(st_length_Spheroid(
     routeline,
     'SPHEROID["GRS_1980",6378137,298.257222101]')) < 600
;

WITH
merged_line as (
  select GeometryType(
          st_linemerge(st_collect(routeline))) as geomtype,
         relation_id,direction
  from tempseg.route_relations_split_lines
  left outer join tempseg.fixed_relations q using(relation_id,direction) where q.relation_id is null
  group by relation_id,direction
  order by geomtype
)
insert into tempseg.fixed_relations (relation_id,direction)
select relation_id,direction
from merged_line where geomtype = 'LINESTRING';

delete
from tempseg.route_relations_split_lines
where
(st_length_Spheroid(
     routeline,
     'SPHEROID["GRS_1980",6378137,298.257222101]')) < 800
;

WITH
merged_line as (
  select GeometryType(
          st_linemerge(st_collect(routeline))) as geomtype,
         relation_id,direction
  from tempseg.route_relations_split_lines
  left outer join tempseg.fixed_relations q using(relation_id,direction) where q.relation_id is null
  group by relation_id,direction
  order by geomtype
)
insert into tempseg.fixed_relations (relation_id,direction)
select relation_id,direction
from merged_line where geomtype = 'LINESTRING';

-- diminishing returns

COMMIT;
