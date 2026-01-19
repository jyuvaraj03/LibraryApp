Ensure your containers are running without any active connections
```bash
docker compose -f docker-compose.dev.yml down
docker compose -f docker-compose.dev.yml up -d
```
1. Reset the Local Database
```bash
# Drop the existing database
docker compose -f docker-compose.dev.yml exec -T db dropdb -U postgres library_app_dev --if-exists
# Create a fresh database
docker compose -f docker-compose.dev.yml exec -T db createdb -U postgres library_app_dev
```
2. Load the SQL Dump
Use the following command to import the db_backup_{timestamp}.sql file into the library_app_dev database:
```bash
cat db_backup_{timestamp}.sql | docker compose -f docker-compose.dev.yml exec -T db psql -U postgres -d library_app_dev
```
3. Verify and Migrate
After loading the data, it's a good practice to run any pending migrations to ensure your schema is up to date with your local code:

```bash
docker compose -f docker-compose.dev.yml exec app bin/rails db:migrate
```
