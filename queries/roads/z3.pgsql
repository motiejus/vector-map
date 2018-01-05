SELECT
  st_linemerge(st_collect(way)) AS __geometry__,
  (
    CASE
      WHEN highway IS NOT NULL
        THEN highway
      WHEN railway IS NOT NULL
        THEN coalesce(service, railway)
      WHEN aeroway IS NOT NULL
        THEN aeroway
    END
  ) AS kind,
  CASE WHEN highway = 'motorway' THEN 1
       WHEN highway = 'trunk' THEN 2
       WHEN highway = 'primary' THEN 3
       WHEN highway = 'secondary' THEN 4
       WHEN highway = 'tertiary' THEN 5
       ELSE 6
  END AS priority,
  name,
  ref,
  length(ref) AS ref_length,
  (
    CASE
      WHEN tunnel IS NOT NULL
        THEN 'yes'
      ELSE 'no'
    END
  ) as is_tunnel,
  (
    CASE
      WHEN bridge IS NOT NULL
        THEN 'yes'
      ELSE 'no'
    END
  ) as is_bridge,
  coalesce(oneway, 'no') AS oneway
FROM
  planet_osm_line
WHERE
  way && !bbox! AND
  (
    highway IN ('motorway', 'motorway_link',
               'trunk', 'trunk_link',
               'primary','primary_link',
               'secondary', 'secondary_link',
               'tertiary', 'tertiary_link',
               'unclassified',
               'residential',
               'living_street',
               'proposed',
               'construction',
               'pedestrian',
               'service',
               'track',
               'footway',
               'steps',
               'path')
   OR
   railway = 'rail' OR
   aeroway IN ('runway', 'taxiway', 'parking_position')
  )
GROUP BY kind, name, priority, ref, is_tunnel, is_bridge, oneway
ORDER BY priority
