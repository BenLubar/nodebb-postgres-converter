#!/bin/bash

set -e

rm -f Makefile secret.go brute_ips

echo 'package main' > secret.go
echo >> secret.go
echo -n 'const secret = ' >> secret.go
docker exec wtdwtf-nodebb node -p 'JSON.stringify(require("./config.json").secret)' >> secret.go

go build -o brute_ips .
docker cp brute_ips wtdwtf-nodebb-postgres:/tmp/brute_ips
docker exec wtdwtf-nodebb-postgres chown postgres:postgres /tmp/brute_ips
rm -f brute_ips secret.go

last_prefix=
sql_files=

ls -- ????.*.sql | sort -r | while IFS=$'\n' read -r name; do
	if [[ "$last_prefix" != "${name%%.*}" ]]; then
		last_prefix="${name%%.*}"
		if ! [[ -z "$sql_files" ]]; then
			echo "$sql_files: $last_prefix" >> Makefile
		fi
		echo ".PHONY: $last_prefix" >> Makefile
		sql_files=$(compgen -G "$last_prefix.*.sql")
		sql_files=${sql_files//$'\n'/ }
		sql_files=${sql_files//\.sql/.do}
		echo "$last_prefix: $sql_files" >> Makefile
	fi
done

echo '.PHONY: %.do' >> Makefile
echo '%.do: %.sql' >> Makefile
echo $'\t''docker exec -iu postgres wtdwtf-nodebb-postgres psql -v ON_ERROR_STOP=1 nodebb < $<' >> Makefile

make "$@"
