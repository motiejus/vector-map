SELECT
  way AS __geometry__,
  highway AS kind,
  ref
FROM
  planet_osm_line
WHERE
  highway IN ('motorway', 'trunk')
  and way && !bbox!
