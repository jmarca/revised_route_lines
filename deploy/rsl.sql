-- Deploy revised_route_lines:rsl to pg
-- requires: more_splits
-- requires: fixed_relations
-- requires: split_lines

BEGIN;

CREATE TABLE  tempseg.revised_route_lines (
  relation_id bigint not null,
  direction text,
  id4 serial primary key,
  unique (relation_id,direction)
);
SELECT AddGeometryColumn( 'tempseg','revised_route_lines', 'routeline',
                          4326, 'GEOMETRY', 2);

INSERT INTO tempseg.revised_route_lines
            (routeline,relation_id,direction)
SELECT
        ST_linemerge(ST_collect(routeline)),
        relation_id,direction
FROM tempseg.more_split_lines
GROUP BY relation_id,direction;

INSERT INTO tempseg.revised_route_lines
            (routeline,relation_id,direction)
SELECT ST_linemerge(ST_collect(routeline)),
       relation_id,direction
FROM tempseg.route_relations_split_lines
JOIN tempseg.fixed_relations q USING(relation_id,direction)
GROUP BY relation_id,direction;


INSERT INTO tempseg.revised_route_lines
            (routeline,relation_id,direction)
SELECT linestring,relation_id,direction
FROM tempseg.initial_routelines
LEFT OUTER JOIN tempseg.revised_route_lines rrl using(relation_id,direction)
WHERE geometrytype(linestring)='LINESTRING'
AND rrl.relation_id IS NULL;


COMMIT;
