-- Deploy revised_route_lines:split_lines to pg
-- requires: initial_routelines

BEGIN;

CREATE TABLE  tempseg.route_relations_split_lines (
  relation_id bigint not null,
  direction text,
  id4 serial primary key,
  segment_id int not null
);
SELECT AddGeometryColumn( 'tempseg','route_relations_split_lines', 'routeline', 4326, 'LINESTRING', 2);

INSERT INTO tempseg.route_relations_split_lines
 (relation_id,direction,segment_id,routeline)
SELECT
  relation_id,direction,
  generate_series(1,(ST_NumGeometries(linestring))*2,2) AS segment_id,
  ST_GeometryN(linestring,
               generate_series(1, ST_NumGeometries(linestring))) AS routeline
FROM tempseg.initial_routelines
WHERE ST_NumGeometries(linestring) IS NOT NULL
ORDER BY relation_id,direction,segment_id
;


COMMIT;
