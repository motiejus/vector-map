SELECT
  way AS __geometry__,
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
      WHEN waterway = 'ditch'
        THEN 'ditch'
      WHEN waterway = 'drain'
        THEN 'drain'
    END
  ) AS kind,
  coalesce("name:lt", name) AS name,
  case when "waterway:name" is null then 'yes' else 'no' end AS through
FROM
  planet_osm_line
WHERE
  way && !bbox! AND
  waterway IN ('dock', 'canal', 'river', 'stream', 'ditch', 'drain')

UNION ALL

SELECT
  st_union(way) AS __geometry__,
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
  null AS name,
  null AS through
FROM
  planet_osm_polygon
WHERE
  way && !bbox! AND
  (
    waterway = 'riverbank' OR
    "natural" = 'water' OR
    landuse IN ('basin', 'reservoir') OR
    amenity = 'swimming_pool' OR
    leisure = 'swimming_pool'
  )
GROUP BY
  kind
