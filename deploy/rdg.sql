-- Deploy revised_route_lines:rdg to pg

BEGIN;

SELECT rr.id as relation_id,sequence_id,linestring,
nextval('tempseg_relation_direction_geometries_seq') as ordering,
       CASE WHEN rr.direction = 'roles' THEN
            CASE WHEN m.member_role='' then 'any'
                 WHEN m.member_role is null then 'any'
                 --handle US:US 6, North&East, West&South
                 WHEN relation_id=337473 then
                      CASE WHEN m.member_role='east' then 'north'
                           WHEN m.member_role='west' then 'south'
                           ELSE m.member_role
                      END
                 ELSE m.member_role
            END
            WHEN rr.direction='' then 'any'
            WHEN rr.direction is null then 'any'
            ELSE rr.direction
       END as direction
into tempseg.relation_direction_geometries
FROM osm.route_relations rr
JOIN osm.relation_members AS m ON (rr.id=m.relation_id)
JOIN osm.ways AS w ON ( member_id = w.id )
WHERE st_npoints(linestring) > 1  -- has to be a line or the st_collect breaks
order by relation_id,direction,sequence_id;

COMMIT;
