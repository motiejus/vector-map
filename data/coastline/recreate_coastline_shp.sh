#!/bin/bash
wget https://osmdata.openstreetmap.de/download/water-polygons-split-3857.zip
unzip water-polygons-split-3857.zip
shp2pgsql -s 3857 -dDI water-polygons-split-3857/water_polygons.shp coastline_tmp | psql gis
rm -rf water-polygons-split-3857*
psql gis < recreate_coastline.sql
pg_dump gis -t coastline -c > coastline.sql
