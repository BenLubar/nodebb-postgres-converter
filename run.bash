#!/bin/bash

set -e

# clean up if we get interrupted
trap 'trap - SIGINT EXIT && kill -INT 0' EXIT SIGINT SIGTERM SIGHUP

start=0
if [[ $# -eq 0 ]]; then
	:
elif [[ $# -eq 1 ]] && [[ "$1" =~ ^[0-9]{1,4}$ ]]; then
	start=$1
else
	echo 'usage: ./run.bash [start-index]' >&2
	exit 1
fi

for i in $(seq -w $start 9999); do
	if ! compgen -G "$i.*.sql" > /dev/null; then
		break
	fi
	for f in $i.*.sql; do
		docker exec -iu postgres wtdwtf-nodebb-postgres psql -v ON_ERROR_STOP=1 nodebb < "$f" &
	done
	wait
done
