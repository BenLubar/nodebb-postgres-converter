nodebb-postgres-converter
=========================

Converts an existing NodeBB NoSQL database to a relational PostgreSQL database.

See also: <https://gist.github.com/BenLubar/dd816c736a9a1cbd70e3469828b96e5d>

Supported database types
========================

- **Redis** 2.8.9+
- **MongoDB** 3.2+
- **PostgreSQL** 9.5+

Instructions
============

Download nodebb-postgres-converter, either by cloning this repository and
running `npm install` or by running `npm install -g nodebb-postgres-converter`
to install globally.

Make a backup of your NodeBB database and decide whether you'd prefer downtime
or the loss of data more recent than your backup. In the future, there will be
a plugin that will record changes made to the live database and then play them
back on the converted database.

Set up your destination database. This can be any of the supported database
types listed above. If you decided to keep the forum running during this
process, set up another copy of your source database(s) from the backup.

Database connection URLs
------------------------

Database connection URLs follow the same format no matter which database you're
using: `type://username:password@ip:port/database`

- **type**: `redis`, `mongodb`, or `postgresql`
- **username:password@**: The username and password for the source/destination
  databases. If you're doing this process on a server where the database cannot
  be accessed externally and you don't have a username or password set up for
  the database, you can skip the `:password` part or the entire authentication
  section of the URL.
- **ip**: The IP address or hostname of the database server.
- **:port**: The port number the database server is listening on. This can be
  skipped if you are using the default port for that database type:
  - **Redis** 6379
  - **MongoDB** 27017
  - **PostgreSQL** 5432
- **database**: The database name (or number for Redis). Common examples
  include `0` for Redis and `nodebb` for MongoDB and PostgreSQL. For a
  PostgreSQL destination, the database must already be created.

PostgreSQL performance tips
---------------------------

Disabling certain safety features in a PostgreSQL destination database will
improve performance. Just remember to turn them back on before going live.

Try running these commands:

```
ALTER SYSTEM SET wal_level = 'minimal';
ALTER SYSTEM SET archive_mode = 'off';
ALTER SYSTEM SET max_wal_senders = 0;
ALTER SYSTEM SET autovacuum = 'off';
```

Followed by restarting the PostgreSQL database before the conversion. After the
conversion, run `ALTER SYSTEM RESET ALL` and restart the database again.

Disabling these features would normally make your database vulnerable to data
loss during a power failure or a crash, but if the conversion process is
interrupted, you can just start over from the backup.

Running the command
-------------------

Now that you're ready, run the command:

- The command starts with `bin/converter.js` if you cloned the repository or
  `nodebb-postgres-converter` if you installed globally.
- Next, add the databases. You always need an output database (`--outputType`,
  `--output`), and you need the object database (`--type`, `--input`) or the
  session database (`--sessionType`, `--sessionInput`) or both.
  - The type is `redis`, `mongo`, or `postgres`, following NodeBB's database
    naming convention.
  - The input or output parameter is a database URL as described above.
- If you're converting to PostgreSQL, adding an argument like `--memory 4GB`
  will make the conversion go faster by temporarily allowing PostgreSQL to use
  up to 4GB of memory for maintenance tasks. PostgreSQL allows 64MB of memory
  by default, so for a large forum, creating indexes and clustering the data
  will take a long time without increasing the memory limit.

If you are running the command remotely (such as over SSH), I suggest using a
program like `screen` to separate the conversion process from your SSH session,
so that the conversion process can continue if your SSH connection is lost.

A complete command looks like this:

```bash
nodebb-postgres-converter \
	--type mongo --input 'mongodb://localhost/nodebb-copy' \
	--sessionType redis --input 'redis://localhost/0' \
	--outputType postgres --output 'postgresql://localhost/nodebb' \
	--memory 12GB
```
