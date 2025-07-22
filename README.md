# Library App

Library app written in Rails

## Technologies Used

- [Ruby on Rails (6.1.4)](https://guides.rubyonrails.org/v6.1.4/) 
- [Stimulus](https://stimulus.hotwired.dev/handbook/introduction)
- [PostgreSQL](https://www.postgresql.org/docs/14/index.html)
- [Docker](https://docs.docker.com/get-started/)
- [Fly.io](https://fly.io/docs/)

## Usage

- Install [Docker](https://docs.docker.com/get-docker/) and [Docker Compose](https://docs.docker.com/compose/install/) for your platform

- Build and start the development environment using Docker Compose
```shell
docker compose -f docker-compose.dev.yml up -d
```

- The application will automatically:
  - Set up PostgreSQL 14 database
  - Install Ruby gems and JavaScript dependencies
  - Create and migrate the database
  - Start the Rails development server

- (Optional) Seed database using values from `db/seeds`. Run this in a separate terminal:
```shell
docker compose -f docker-compose.dev.yml exec app rails db:seed
```

```shell
docker compose -f docker-compose.dev.yml exec app bin/dev
```

- The application is now available at `http://localhost:3000`!

- To stop the development environment:
```shell
docker compose -f docker-compose.dev.yml down
```

## CSV Import/Export

The application includes functionality to import and export books and members as CSV files.

### Rake Tasks

```shell
# Export books to CSV
rails csv:export_books

# Export members to CSV  
rails csv:export_members

# Import books from CSV
rails csv:import_books FILENAME=books.csv

# Import members from CSV
rails csv:import_members FILENAME=members.csv
```

For detailed usage instructions, see [CSV Import/Export Documentation](doc/CSV_IMPORT_EXPORT.md).

## Deployment

- Deployment uses [Fly.io](https://fly.io/) platform.
- Make sure you have the [Fly CLI](https://fly.io/docs/hands-on/install-flyctl/) installed and are logged in:
```shell
fly auth login
```
- Run migrations on the deployed application:
```shell
fly ssh console -a muthamizh-mandram -C "rails db:migrate"
```
- Deploy the application to Fly.io:
```shell
fly deploy
```

## Roadmap

This will always be a moving target because, well, software development is an iterative process.

- [~~i18n~~](https://guides.rubyonrails.org/i18n.html) :earth_africa:
- Sorting tables :arrow_up::arrow_down:
- Different permissions for librarians and admins :man_technologist: :woman_technologist: 
- Handle renewals as a separate entity (currently renewals are done by returning and re-borrowing the book) :repeat_one:
- More filters :pencil:
- Potential optimisations :sparkles:
    - [Code splitting](https://webpack.js.org/guides/code-splitting/)
    - [Full text search GIN indexes](https://thoughtbot.com/blog/optimizing-full-text-search-with-postgres-tsvector-columns-and-triggers)
- Home page statistics :chart:
