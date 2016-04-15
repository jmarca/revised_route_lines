-- Verify revised_route_lines:rsl on pg

BEGIN;

select relation_id,direction,id4,routeline
from tempseg.revised_route_lines
where false;

select 1/count(*)
from tempseg.revised_route_lines;


ROLLBACK;
