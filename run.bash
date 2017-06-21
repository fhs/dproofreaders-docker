#!/bin/bash

set -e

docker stop pgdp-sql
docker rm pgdp-sql
docker run --name=pgdp-sql --network=pgdp \
	-e 'MYSQL_ROOT_PASSWORD=dp_password' -d mysql:5.7

sleep 10

docker stop pgdp-web
docker rm pgdp-web
docker run --name=pgdp-web --network=pgdp -d pgdp-web
