-- Verify revised_route_lines:rdg_seq on pg

BEGIN;

SELECT pg_catalog.has_sequence_privilege('tempseg_relation_direction_geometries_seq', 'usage');

ROLLBACK;
