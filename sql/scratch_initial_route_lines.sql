-- first fix the directions of any to be all





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
