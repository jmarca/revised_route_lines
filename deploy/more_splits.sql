-- Deploy revised_route_lines:more_splits to pg
-- requires: fixed_relations
-- requires: split_lines

BEGIN;

CREATE TABLE  tempseg.more_split_lines (
  relation_id bigint not null,
  direction text,
  id4 serial primary key,
  fix boolean default false,
  segment_id int not null
);
SELECT AddGeometryColumn( 'tempseg','more_split_lines',
                          'routeline', 4326, 'LINESTRING', 2);


WITH
split_not_fixed as (
   select st_linemerge(st_collect(routeline)) as linestring,
         relation_id,direction
   from tempseg.route_relations_split_lines
   left outer join tempseg.fixed_relations q using(relation_id,direction)
   where q.relation_id is null
   group by relation_id,direction
)
INSERT INTO tempseg.more_split_lines
            (relation_id,direction,segment_id,routeline)
SELECT relation_id,direction,
       generate_series(1,(Select ST_NumGeometries(linestring))*2,2) as segment_id,
       ST_GeometryN(linestring,
                    generate_series(1, ST_NumGeometries(linestring))
                    ) AS routeline
from split_not_fixed
where ST_NumGeometries(linestring) is not null;


-- self join, construct joining segments


INSERT INTO tempseg.more_split_lines
            (relation_id, direction, segment_id, fix,routeline)
SELECT rl1.relation_id, rl1.direction,
       rl1.segment_id + 1 as segment_id,
       true as fix,
       st_makeline(
             st_endpoint(rl1.routeline),
             st_startpoint(rl2.routeline)
       ) as routeline
FROM tempseg.more_split_lines rl1
JOIN tempseg.more_split_lines rl2
     USING (relation_id,direction,segment_id)
WHERE NOT ST_equals(
             ST_endpoint(rl1.routeline),
             ST_startpoint(rl2.routeline)
             )
      AND ST_Distance_Sphere(
             ST_endpoint(rl1.routeline),
             ST_startpoint(rl2.routeline)
             ) < 1000
;


COMMIT;
