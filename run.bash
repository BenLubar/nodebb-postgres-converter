#!/bin/bash

set -e

if [[ "$#" -eq 0 ]]; then
	echo './run.bash requires MAKE(1) parameters.'
	echo 'Run "./run.bash -j1" for generic "make".'
	exit 2
fi

rm -f Makefile secret.go brute_ips

echo 'package main' > secret.go
echo >> secret.go
echo -n 'const secret = ' >> secret.go
docker cp wtdwtf-nodebb:/usr/src/app/docker/config.json .
node -p 'JSON.stringify(require("./config.json").secret)' >> secret.go

go build -o brute_ips .
docker cp brute_ips wtdwtf-nodebb-postgres:/tmp/brute_ips
docker exec wtdwtf-nodebb-postgres chown postgres:postgres /tmp/brute_ips
rm -f brute_ips secret.go config.json

go run generate_makefile.go > Makefile

postgres_ip=$(docker inspect -f '{{.NetworkSettings.Networks.wtdwtf.IPAddress}}' wtdwtf-nodebb-postgres)

echo '.PHONY: %.do' >> Makefile
echo '%.do: %.sql' >> Makefile
echo $'\t'"@echo Running $<..." >> Makefile
echo $'\t'"@psql -q -h $postgres_ip"' -U postgres -c "SET CLIENT_MIN_MESSAGES TO WARNING" -v ON_ERROR_STOP=1 -P pager=off nodebb -1 -b -f $<' >> Makefile

make "$@" || echo 'FAILED!'
