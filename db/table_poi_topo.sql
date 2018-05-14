drop materialized view if exists poi_topo;
create materialized view poi_topo (
  id
 ,__type__
 ,name
 ,amenity
 ,man_made
 ,"tower:type"
 ,tourism
 ,"attraction:type"
 ,access
 ,historic
 ,religion
 ,aeroway
 ,power
 ,landuse
 ,building
 ,way
) as
  select
        osm_id
        ,'n' -- always node
        ,name
        ,amenity
        ,man_made
        ,"tower:type"
        ,tourism
        ,"attraction:type"
        ,access
        ,historic
        ,religion
        ,aeroway
        ,power
        ,landuse
        ,building
        ,way
    from planet_osm_point
   where aeroway in ('aerodrome', 'helipad')
      or amenity = 'place_of_worship'
      or man_made in ('chimnei', 'windmill', 'watermill', 'tower')
      or amenity = 'fuel'
      or power = 'substation'
  union
  select
        ABS(osm_id)
        ,CASE WHEN osm_id < 0 THEN 'r' ELSE 'w' END  -- r relation, w way
        ,name
        ,amenity
        ,man_made
        ,"tower:type"
        ,tourism
        ,null --"attraction:type"
        ,access
        ,historic
        ,religion
        ,aeroway
        ,power
        ,landuse
        ,building
        ,st_centroid(way)
    from planet_osm_polygon
   where aeroway in ('aerodrome', 'helipad')
      or amenity = 'place_of_worship'
      or man_made in ('chimnei', 'windmill', 'watermill', 'tower')
      or amenity = 'fuel'
      or landuse = 'quary'
      or power = 'substation';
