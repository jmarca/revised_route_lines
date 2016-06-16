SET client_min_messages TO warning;
CREATE EXTENSION IF NOT EXISTS pgtap;
RESET client_min_messages;

BEGIN;
SELECT no_plan();
-- SELECT plan(1);

SELECT pass('Test split_lines!');

PREPARE tallyup AS
   SELECT count(*)::integer
   FROM tempseg.route_relations_split_lines;

PREPARE this_or_that AS
   SELECT CASE
            WHEN exists(SELECT tablename
                        FROM pg_tables
                        WHERE schemaname='tempseg'
                          AND tablename='fixed_relations')
            THEN 1884
            ELSE 2799
            END;


SELECT results_eq( 'tallyup', 'this_or_that', 'The data got loaded okay');

SELECT finish();
ROLLBACK;
