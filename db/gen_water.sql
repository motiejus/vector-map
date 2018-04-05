drop table if exists gen_water;
create table gen_water as
  select 0 AS way_area
        ,10 AS res
        ,ST_CollectionExtract(unnest(ST_ClusterWithin(way, 10)), 3)::geometry(MultiPolygon, 3857) as way
    from planet_osm_polygon
   where "natural" = 'water' or landuse = 'reservoir';

delete from gen_water where st_area(st_buffer(way, -10)) < 10 and res = 10;

update gen_water set way = st_multi(st_simplifypreservetopology(st_buffer(st_buffer(way, 10, 'quad_segs=1'), -10, 'quad_segs=1'), 10)) where res = 10;
update gen_water set way_area = st_area(way) where res = 10;

insert into gen_water
  select 0,
         150,
         ST_CollectionExtract(unnest(ST_ClusterWithin(way, 150)), 3)::geometry(MultiPolygon, 3857)
    from gen_water
   where res = 10;

delete from gen_water where st_area(st_buffer(way, -150)) < 150 and res = 150;

update gen_water set way = st_multi(st_simplifypreservetopology(st_buffer(st_buffer(way, 150, 'quad_segs=1'), -150, 'quad_segs=1'), 150)) where res = 150;
update gen_water set way_area = st_area(way) where res = 150;

insert into gen_water
  select 0,
         600,
         ST_CollectionExtract(unnest(ST_ClusterWithin(way, 600)), 3)::geometry(MultiPolygon, 3857)
    from gen_water
   where res = 150;

delete from gen_water where st_area(st_buffer(way, -600)) < 600 and res = 600;

update gen_water set way = st_multi(st_simplifypreservetopology(st_buffer(st_buffer(way, 600, 'quad_segs=1'), -600, 'quad_segs=1'), 300)) where res = 600;
update gen_water set way_area = st_area(way) where res = 600;

create index gen_building_gix ON gen_water using gist (way);