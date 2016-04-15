-- Verify revised_route_lines:more_splits on pg

BEGIN;

select relation_id,direction,id4,fix,segment_id,routeline
from tempseg.more_split_lines
where false;

select 1/count(*)
from tempseg.more_split_lines;


ROLLBACK;
