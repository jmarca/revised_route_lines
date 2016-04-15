-- Revert revised_route_lines:split_lines from pg

BEGIN;

DROP TABLE tempseg.route_relations_split_lines;

COMMIT;
