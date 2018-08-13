#!/bin/bash

set -e

rm -f Makefile

last_prefix=
sql_files=

ls ????.*.sql | sort -r | while IFS=$'\n' read -r name; do
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
