SELECT
  id AS __id__,
  way AS __geometry__,
  'forest' AS kind
FROM
  gen_forest
WHERE
  way && !bbox! AND
  res = 150 AND
  way_area >= 1000000
