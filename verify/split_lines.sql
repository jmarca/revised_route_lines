-- Verify revised_route_lines:split_lines on pg

BEGIN;

select relation_id,direction,id4,segment_id,routeline
from tempseg.route_relations_split_lines
where false;

select 1/count(*)
from tempseg.route_relations_split_lines;

ROLLBACK;
