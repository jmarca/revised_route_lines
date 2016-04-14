-- first fix the directions of any to be all

drop table if exists tempseg.nother_table;
select rdg.relation_id,rdg.sequence_id,rdg.linestring,rdg.ordering,b.direction
into tempseg.nother_table
from tempseg.relation_direction_geometries rdg
join (select distinct relation_id,direction
      from tempseg.relation_direction_geometries d
      where direction != 'any') b on (b.relation_id=rdg.relation_id)
where rdg.direction='any';



drop table if exists tempseg.initial_routelines cascade;
select relation_id,
       direction,
-- st_numGeometries(st_linemerge(st_collect(linestring)))
 st_linemerge(st_collect(linestring))
 as linestring
into tempseg.initial_routelines
from (
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
 from tempseg.nother_table n
) q group by relation_id,direction;

--  now add the 'any' direction ones
insert into tempseg.initial_routelines
select relation_id,
       'both' as direction,
-- st_numGeometries(st_linemerge(st_collect(linestring)))
 st_linemerge(st_collect(linestring))
 as linestring
from (
 select rdg.relation_id,
       rdg.direction,
       rdg.linestring,
       rdg.sequence_id
 from tempseg.relation_direction_geometries rdg
 where rdg.direction = 'any' and
       rdg.relation_id not in (select distinct relation_id from tempseg.nother_table)
) a
group by relation_id, direction;
