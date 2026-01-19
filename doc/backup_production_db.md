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
echo $DATABASE_URL
```

The database URL should look something like this:
```
postgres://user:password@muthamizh-mandram-db.flycast:5432/muthamizh_mandram?sslmode=disable
```
3. Use pg_dump to dump the database contents from the proxied production postgres connection
```bash
# Make sure to switch the muthamizh-mandram-db.flycast:5432 from above to localhost:15432
pg_dump postgres://user:password@localhost:15432/muthamizh_mandram?sslmode=disable -f db_backup_$(date +%s).sql
```
