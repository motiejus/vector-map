SELECT
  osm_id AS gid,
  ST_AsBinary(way) AS geom,
  coalesce("name:lt", name) AS name,
  (
    CASE
      WHEN place = 'town' AND rank = '0'
        THEN 'town'
      WHEN place = 'town' AND rank = '10'
        THEN 'little_town'
      WHEN place = 'town' AND rank = '20'
        THEN 'railway_station'
      ELSE place
    END
  ) AS kind
FROM
  planet_osm_point
WHERE
  way && !BBOX! AND
  name IS NOT NULL AND
  place IN ('city', 'town', 'village', 'suburb')

UNION ALL

SELECT
  osm_id AS gid,
  ST_AsBinary(ST_PointOnSurface(way)) AS geom,
  coalesce("name:lt", name) AS name,
  'water' AS kind
FROM
  planet_osm_polygon
WHERE
  way && !BBOX! AND
  name IS NOT NULL AND
  ("natural" = 'water' OR landuse = 'reservoir') AND
  way_area >= 100000
