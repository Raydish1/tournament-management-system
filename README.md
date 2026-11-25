## Proj

install postgres (homebrew for mac/linux) then start as process.

then:

`psql postgres`

then:

`CREATE USER admin WITH PASSWORD 'admin';`

then:

`CREATE DATABASE tournament OWNER admin;`

by this point, we have a database `tournament` that we can connect to at `localhost` using port `5432` and credentials `admin:admin`

from root project directory, initialize the db (write the schema) once:

`python3 db/init.py`

at this point, we can see schema was written to tournament db via:
```
psql -h localhost -p 5432 -U admin -d tournament 
\c tournament
\dt
\di
```

