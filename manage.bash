#!/bin/bash

set -e

NET=dproofreaders
PHPBB_VER=3.0.14
DP_VER=R201701
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

downloadsrc(){
	(
		cd app/src
		if [ ! -e "phpBB-${PHPBB_VER}.tar.bz2" ]
		then
			curl -L -O "https://www.phpbb.com/files/release/phpBB-${PHPBB_VER}.tar.bz2"
		fi
		if [ ! -e "dproofreaders.${DP_VER}.tgz" ]
		then
			curl -L -O "https://downloads.sourceforge.net/project/dproofreaders/dproofreaders/${DP_VER}/dproofreaders.${DP_VER}.tgz"
		fi
	)
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
	downloadsrc
	docker build --network=pgdp -t ${DP_IMAGE}:${DP_VER} -t ${DP_IMAGE}:latest .
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
