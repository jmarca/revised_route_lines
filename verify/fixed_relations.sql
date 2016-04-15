-- Verify revised_route_lines:fixed_relations on pg

BEGIN;

select relation_id,direction
from tempseg.fixed_relations
where false;

select 1/count(*)
from tempseg.fixed_relations;


ROLLBACK;
