-- Revert revised_route_lines:initial_routelines from pg

BEGIN;

DROP TABLE tempseg.initial_routelines;

COMMIT;
