-- Revert revised_route_lines:tempseg_schema from pg

BEGIN;

DROP SCHEMA tempseg;

COMMIT;
