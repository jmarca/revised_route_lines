-- Revert revised_route_lines:rdg_seq from pg

BEGIN;

DROP SEQUENCE tempseg_relation_direction_geometries_seq;

COMMIT;
