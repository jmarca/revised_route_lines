-- Verify revised_route_lines:rdg on pg

BEGIN;

SELECT relation_id,sequence_id,linestring,ordering,direction
FROM tempseg.relation_direction_geometries
 WHERE FALSE;

ROLLBACK;
