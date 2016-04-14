CREATE SEQUENCE tempseg_relation_direction_geometries_seq increment by 2;

SELECT rr.id as relation_id,sequence_id,linestring,
nextval('tempseg_relation_direction_geometries_seq') as ordering,
       CASE WHEN rr.direction = 'roles' THEN
            CASE WHEN m.member_role='' then 'any'
                 WHEN m.member_role is null then 'any'
                 --handle US:US 6, North&East, West&South
                 WHEN relation_id=337473 then
                      CASE WHEN m.member_role='east' then 'north'
                           WHEN m.member_role='west' then 'south'
                           ELSE m.member_role
                      END
                 ELSE m.member_role
            END
            WHEN rr.direction='' then 'any'
            WHEN rr.direction is null then 'any'
            ELSE rr.direction
       END as direction
-- into tempseg.relation_direction_geometries
FROM osm.route_relations rr
JOIN osm.relation_members AS m ON (rr.id=m.relation_id)
JOIN osm.ways AS w ON ( member_id = w.id )
WHERE st_npoints(linestring) > 1  -- has to be a line or the st_collect breaks
-- and relation_id=69364
order by relation_id,direction,sequence_id;


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
