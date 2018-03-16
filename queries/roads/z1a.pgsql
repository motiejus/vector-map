SELECT
  r.__geometry__
 ,r.kind
 ,r.priority
 ,r.ref
 ,r.ref_length
FROM
(SELECT
  st_linemerge(st_collect(way)) AS __geometry__,
  highway AS kind,
  CASE WHEN highway = 'motorway' THEN 1
       WHEN highway = 'trunk' THEN 2
       WHEN highway = 'primary' THEN 3
       WHEN highway = 'secondary' THEN 4
       WHEN highway = 'tertiary' THEN 5
       ELSE 6
  END AS priority,
  ref,
  length(ref) AS ref_length
FROM
  planet_osm_line
WHERE
  way && !bbox! AND
  (
    highway IN ('motorway_link',
               'trunk_link',
               'primary_link',
               'secondary', 'secondary_link',
               'tertiary', 'tertiary_link',
               'unclassified')
  )
GROUP BY kind, priority, ref

UNION ALL

SELECT
  st_linemerge(st_collect(way)) AS __geometry__,
  type AS kind,
  CASE WHEN type = 'motorway' THEN 1
       WHEN type = 'trunk' THEN 2
       WHEN type = 'primary' THEN 3
       ELSE 6
  END AS priority,
  subtype AS ref,
  length(subtype) AS ref_length
FROM
  gen_ways
WHERE
  way && !bbox! AND
  type != 'rail'
GROUP BY kind, priority, ref

UNION ALL

SELECT
  way AS __geometry__,
  'rail' AS kind,
  7 AS priority,
  null as ref,
  null ref_length
FROM
  gen_ways
WHERE
  way && !bbox! AND
  type = 'rail'
) AS r
ORDER BY r.priority
