SELECT
  st_linemerge(st_collect(way)) AS __geometry__,
  route AS kind,
  network,
  name,
  distance
FROM
  planet_osm_line
WHERE
  way && !bbox! AND
  route IN ('bicycle')
GROUP BY
  route, network, name, distance
