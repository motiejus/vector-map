SELECT
  geom AS __geometry__,
  'coastline' AS kind
FROM
  coastline
WHERE
  geom && !bbox!