SELECT
  osm_id AS gid,
  st_asbinary(way) AS geom,
  (
    CASE
      WHEN waterway = 'dock'
        THEN 'dock'
      WHEN waterway = 'canal'
        THEN 'canal'
      WHEN waterway = 'river'
        THEN 'river'
      WHEN waterway = 'stream'
        THEN 'stream'
    END
  ) AS kind,
  coalesce("name:lt", name) AS name
FROM
  planet_osm_line
WHERE
  way && !BBOX! AND
  waterway IN ('dock', 'canal', 'river', 'stream', 'ditch') AND
  "waterway:speed" is null

UNION ALL

SELECT
  row_number() over() AS gid,
  st_asbinary(st_union(way)) AS geom,
  (
    CASE
      WHEN waterway = 'riverbank'
        THEN 'water'
      WHEN "natural" = 'water'
        THEN 'water'
      WHEN landuse = 'basin'
        THEN 'basin'
      WHEN landuse = 'reservoir'
        THEN 'water'
      WHEN amenity = 'swimming_pool' OR leisure = 'swimming_pool'
        THEN 'swimming_pool'
    END
  ) AS kind,
  null AS name
FROM
  planet_osm_polygon
WHERE
  way && !BBOX! AND
  (
    waterway = 'riverbank' OR
    "natural" = 'water' OR
    landuse IN ('basin', 'reservoir') OR
    amenity = 'swimming_pool' OR
    leisure = 'swimming_pool'
  ) AND
  way_area >= 5000
GROUP BY
  kind
