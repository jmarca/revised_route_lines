SET client_min_messages TO warning;
CREATE EXTENSION IF NOT EXISTS pgtap;
RESET client_min_messages;

BEGIN;
SELECT no_plan();
-- SELECT plan(1);

SELECT pass('Test rdg!');

SELECT is(
    (SELECT count(*)
          FROM tempseg.relation_direction_geometries
    )::integer,
    38484,
    'The data got loaded okay'
);

SELECT finish();
ROLLBACK;
