# AGENTS.md

## Project Overview

LibraryApp is a Rails 6.1.4 application for managing a library workflow: books, members, staff login, rentals, and returns.

### Core stack

- Ruby 3.2.2
- Rails 6.1.4
- PostgreSQL 14
- Stimulus / Webpacker
- Tailwind CSS 2
- Pundit for authorization
- Pagy for pagination
- pg_search for search
- rails-i18n for localization

### Main domains

- `books` for catalog management
- `members` for patron records
- `book_rentals` for checkout flow
- `returns` for book returns
- `member_book_rentals` for member history
- `sessions` for staff authentication

## Repository Layout

- `app/controllers`, `app/models`, `app/policies`, `app/helpers`: Rails application code
- `app/views`: UI templates
- `app/javascript/controllers`: Stimulus controllers
- `app/assets/stylesheets`: CSS and Tailwind entrypoint
- `db/migrate`, `db/seeds`: schema and seed data
- `lib/tasks`: custom rake tasks, including CSV import/export
- `doc/CSV_IMPORT_EXPORT.md`: CSV task documentation
- `test`: Minitest test suite with fixtures

## How To Run It

Preferred local setup is Docker Compose:

```sh
docker compose -f docker-compose.dev.yml up -d
docker compose -f docker-compose.dev.yml exec app bin/dev
```

The app should be available at `http://localhost:3000`.

Useful companion commands:

```sh
docker compose -f docker-compose.dev.yml exec app rails db:seed
docker compose -f docker-compose.dev.yml down
```

The dev process is driven by `Procfile.dev`:

- `web`: Rails server on port 3000
- `css`: Tailwind watcher
- `webpacker`: webpack dev server

## Testing

Run the Minitest suite through Rails:

```sh
rails test
```

The test helper loads all fixtures and runs tests in parallel. Existing tests are organized by controller, model, integration, helper, task, and system coverage.

## Working Conventions

- Follow the existing Rails structure and naming conventions.
- Keep business logic in models, policies, and service-style code where the app already uses it.
- Use Pundit for authorization checks; `ApplicationController` maps `Pundit::NotAuthorizedError` to a redirect with a flash message.
- Respect localization: the app sets `I18n.locale` from `ENV['LOCALE']`.
- Prefer editing source files over generated output in `app/assets/builds` or other build artifacts.
- Update or add tests alongside behavior changes, especially for controllers, models, and rake tasks.

## Notable Entry Points

- `config/routes.rb` defines the user-facing flow
- `app/controllers/application_controller.rb` defines shared auth, pagination, locale, and policy behavior
- `test/test_helper.rb` defines fixtures and test helpers
- `lib/tasks/csv_import_export.rake` contains CSV import/export tasks

## Notes For Future Changes

- The app uses staff login via `/login` and `/logout`.
- The root route is `books#index`.
- CSV workflows are documented in `doc/CSV_IMPORT_EXPORT.md`; check that before changing import/export behavior.
- Keep changes scoped to the relevant feature area unless a broader refactor is explicitly needed.
