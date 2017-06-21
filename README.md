# dproofreaders-docker
Dockerfile for [dproofreaders](https://sourceforge.net/projects/dproofreaders/). Images are available in [Docker Hub](https://hub.docker.com/r/fshahriar/dproofreaders/).

**This docker image is for testing purposes only. It has hardcoded passwords. Do not use in production.**

Run as following:
```
./manage.bash run
```
which does the same thing as:
```
docker network create dproofreaders
docker run -d --network=dproofreaders --name=pgdp-sql -e 'MYSQL_ROOT_PASSWORD=dp_password' mysql:5.7
docker run -d --network=dproofreaders --name=pgdp-web fshahriar/dproofreaders
docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' pgdp-web  # server-ip
```

Visit the site at `http://<server-ip>/`.
A default admin user "admin" is created with password "admin". PhpBB (at `http://<server-ip>/phpBB3/`) also has a default admin user "bbadmin" with password "bbadmin". MySQL username/password (root/dp_password) is hardcoded everywhere.
