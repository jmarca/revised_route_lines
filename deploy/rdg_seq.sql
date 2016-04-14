-- Deploy revised_route_lines:rdg_seq to pg
-- requires: osm_via_osmosis:route_relations

BEGIN;

CREATE SEQUENCE tempseg_relation_direction_geometries_seq increment by 2;

COMMIT;
