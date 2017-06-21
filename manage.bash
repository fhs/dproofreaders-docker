#!/bin/bash

set -e

NET=dproofreaders
VERSION=R201701
DP_IMAGE=fshahriar/dproofreaders

containerstatus(){
	docker inspect -f '{{.State.Status}}' "$1" 2>/dev/null
}

runimg(){
	name=$1
	shift

	case "$(containerstatus ${name})" in
	running)
		echo $name already running
		;;
	exited)
		echo docker start $name	'#' currently stopped
		;;
	*)
		docker run -d --restart=always --network=$NET \
			--name=${name} --hostname=${name} "$@"
		;;
	esac
}

if ! docker network inspect "$NET" >/dev/null 2>&1
then
	docker network create $NET
fi

showurl(){
	IP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' pgdp-web)
	echo http://${IP}/
}

case "$1" in
url)
	showurl
	;;
kill)
	docker stop pgdp-sql pgdp-web
	docker rm pgdp-sql pgdp-web
	;;
build)
	docker build -t ${DP_IMAGE}:${VERSION} -t ${DP_IMAGE}:latest .
	;;
run)
	runimg pgdp-sql -e 'MYSQL_ROOT_PASSWORD=dp_password' mysql:5.7
	sleep 10 # wait for mysql to start up
	runimg pgdp-web $DP_IMAGE
	showurl
	;;
*)
	echo usage: $0 '<url|kill|build|run>'
	exit 2
	;;
esac
