-- Revert revised_route_lines:fixed_relations from pg

BEGIN;

drop table tempseg.fixed_relations;

COMMIT;
