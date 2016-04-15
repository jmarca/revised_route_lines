-- Revert revised_route_lines:rsl from pg

BEGIN;

drop table tempseg.revised_route_lines;

COMMIT;
