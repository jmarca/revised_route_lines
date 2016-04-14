-- okay, that has pretty much run out of its usefulness.  Now I need
-- to insert segments as needed.  My thought is for those geoms with
-- two or three parts, make segments to join the parts, if that
-- segment is less than 1km

-- how?

-- select geometry 1 of N, last point, join with first point, geometry 2 of N

-- so make a new temp table

drop table if exists tempseg.more_split_lines cascade;
CREATE TABLE  tempseg.more_split_lines (
  relation_id bigint not null,
  direction text,
  id4 serial primary key,
  segment_id int not null
);
SELECT AddGeometryColumn( 'tempseg','more_split_lines', 'routeline', 4326, 'LINESTRING', 2);


insert into tempseg.more_split_lines
 (relation_id,direction,segment_id,routeline)
SELECT
  relation_id,direction,generate_series(1,(Select ST_NumGeometries(linestring))*2,2) as segment_id,
ST_GeometryN(linestring, generate_series(1, ST_NumGeometries(linestring))) AS routeline
from (
  select st_linemerge(st_collect(routeline)) as linestring,
         relation_id,direction
  from tempseg.route_relations_split_lines
  left outer join tempseg.fixed_relations q using(relation_id,direction)
  where q.relation_id is null
  group by relation_id,direction
) b
where ST_NumGeometries(linestring) is not null;


alter table tempseg.more_split_lines add column fix boolean default false;

-- self join, construct joining segments

insert into tempseg.more_split_lines
  (relation_id, direction, segment_id, fix,routeline)
  select rl1.relation_id, rl1.direction,rl1.segment_id + 1 as segment_id,
       true as fix,
       st_makeline(
             st_endpoint(rl1.routeline),
             st_startpoint(rl2.routeline)
       ) as routeline
  from tempseg.more_split_lines rl1
  join tempseg.more_split_lines rl2
       on (rl1.relation_id=rl2.relation_id
           and rl1.direction = rl2.direction
           and rl1.segment_id + 2 = rl2.segment_id
          )
  where not ST_equals(st_endpoint(rl1.routeline),
             st_startpoint(rl2.routeline))
  and ST_Distance_Sphere(st_endpoint(rl1.routeline),
             st_startpoint(rl2.routeline)) < 1000
;

-- select  GeometryType(st_linemerge(st_collect(routeline))) as geomtype,
--        relation_id,direction
-- from tempseg.more_split_lines
-- group by relation_id,direction
-- order by geomtype;

-- Okay, that is as good as I can get for now

drop table if exists tempseg.revised_route_lines cascade;
CREATE TABLE  tempseg.revised_route_lines (
  relation_id bigint not null,
  direction text,
  id4 serial primary key,
  unique (relation_id,direction)
);
SELECT AddGeometryColumn( 'tempseg','revised_route_lines', 'routeline', 4326, 'GEOMETRY', 2);


insert into tempseg.revised_route_lines
(routeline,relation_id,direction)
select  st_linemerge(st_collect(routeline)),
       relation_id,direction
from tempseg.more_split_lines
group by relation_id,direction;

insert into tempseg.revised_route_lines
(routeline,relation_id,direction)
select st_linemerge(st_collect(routeline)),
       relation_id,direction
from tempseg.route_relations_split_lines
join tempseg.fixed_relations q using(relation_id,direction)
group by relation_id,direction;


insert into tempseg.revised_route_lines
(routeline,relation_id,direction)
select linestring,relation_id,direction
from tempseg.initial_routelines
where geometrytype(linestring)='LINESTRING';
