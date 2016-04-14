-- Revert revised_route_lines:rdg from pg

BEGIN;

DROP TABLE tempseg.relation_direction_geometries;

COMMIT;
