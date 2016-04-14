-- Verify revised_route_lines:tempseg_schema on pg

BEGIN;

SELECT pg_catalog.has_schema_privilege('tempseg','usage');

ROLLBACK;
