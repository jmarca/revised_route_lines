SET client_min_messages TO warning;
CREATE EXTENSION IF NOT EXISTS pgtap;
RESET client_min_messages;

BEGIN;
SELECT no_plan();
-- SELECT plan(1);

SELECT pass('Test split_lines!');


SELECT is(
    (SELECT count(*)
          FROM tempseg.route_relations_split_lines
    )::integer,
    (select CASE
            WHEN exists(SELECT tablename
                        FROM pg_tables
                        WHERE schemaname='tempseg'
                          AND tablename='fixed_relations')
            THEN 1884
            ELSE 2799
            END),
    'The data got loaded okay'
);

SELECT finish();
ROLLBACK;
