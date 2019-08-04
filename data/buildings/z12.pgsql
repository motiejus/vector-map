SELECT
  id AS gid,
  st_asbinary(way) AS geom,
  'yes' AS kind,
  null AS name,
  null AS height
FROM
  gen_building
WHERE
  way && !BBOX! AND
  way_area > 320 AND
  res = 10
