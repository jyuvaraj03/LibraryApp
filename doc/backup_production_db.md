1. Open a proxy to fly database
```bash
fly proxy 15432:5432 -a muthamizh-mandram-db
```
2. Get the `DATABASE_URL` from the app console
```bash
# To keep fly.io from shutting down the machine,
watch -n 30 curl https://muthamizh-mandram.fly.dev/
```
```bash
# In another console, from inside the root of this folder
fly ssh console
```
```bash
# Inside the console, run the following command to get the DATABASE_URL
echo $DATABASE_URL | sed 's/muthamizh-mandram-db.flycast:5432/localhost:15432/'
```

The database URL should look something like this:
```
postgres://user:password@localhost:15432/muthamizh_mandram?sslmode=disable
```
3. Use pg_dump to dump the database contents from the proxied production postgres connection
```bash
# Make sure to switch the muthamizh-mandram-db.flycast:5432 from above to localhost:15432
DATABASE_URL="postgres://user:password@localhost:15432/muthamizh_mandram?sslmode=disable"
pg_dump $DATABASE_URL -f db_backup_$(date +%s).sql
```
