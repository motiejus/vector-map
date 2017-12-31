#!/usr/bin/env bash

if [ ! -e data.pbf ]; then
	wget -O data.pbf http://osm.ramuno.lt/vilnius.pbf
fi

CONTAINER_DB=`docker-compose ps -q db`
# install shp2pgsql
docker exec $CONTAINER_DB sh -c 'apt update -qy && apt install -qy postgis'

# load data
docker run --rm -it -w /tmp/src -v `pwd`:/tmp/src --network "container:$CONTAINER_DB" -e PGPASSWORD=osm openmap/osm2pgsql:latest osm2pgsql -s -c -C 512 --multi-geometry -S db/osm2pgsql.style -d osm -U osm -H db data.pbf
docker exec -u postgres $CONTAINER_DB sh -c 'psql osm -f /src/db/index.sql'
docker exec -u postgres $CONTAINER_DB sh -c 'psql osm -f /src/db/table_poi.sql'
docker exec -u postgres $CONTAINER_DB sh -c 'shp2pgsql -dDI -s 3857 /src/queries/coastline/coastline.shp | psql osm'
