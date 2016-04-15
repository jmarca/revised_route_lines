-- Revert revised_route_lines:more_splits from pg

BEGIN;

drop table tempseg.more_split_lines;

COMMIT;
