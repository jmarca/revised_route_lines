-- Verify revised_route_lines:initial_routelines on pg

BEGIN;

SELECT relation_id,direction,linestring
FROM tempseg.initial_routelines
 WHERE FALSE;

ROLLBACK;
