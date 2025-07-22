# CSV Import/Export Tasks

This document describes the rake tasks available for importing and exporting books and members as CSV files.

## Available Tasks

### Export Tasks

#### Export Books
```bash
rails csv:export_books
```
Exports all books to a CSV file with timestamp in the filename.

**Custom filename:**
```bash
rails csv:export_books FILENAME=my_books_export.csv
```

**CSV Format for Books:**
- `custom_number` - Book's custom identifier
- `name` - Book title
- `publishing_year` - Year of publication
- `author_name` - Author's name
- `publisher_name` - Publisher's name
- `category_names` - Comma-separated list of categories

#### Export Members
```bash
rails csv:export_members
```
Exports all members to a CSV file with timestamp in the filename.

**Custom filename:**
```bash
rails csv:export_members FILENAME=my_members_export.csv
```

**CSV Format for Members:**
- `custom_number` - Member's custom identifier
- `personal_number` - Member's personal number
- `name` - Member's name
- `tamil_name` - Member's name in Tamil
- `email` - Email address
- `phone` - Phone number
- `section` - Department/section
- `date_of_birth` - Birth date (YYYY-MM-DD format)
- `date_of_retirement` - Retirement date (YYYY-MM-DD format)

### Import Tasks

#### Import Books
```bash
rails csv:import_books FILENAME=books_to_import.csv
```
Imports books from the specified CSV file. The CSV file must be in the `tmp/` directory.

**Features:**
- Creates associated authors, publishers, and categories if they don't exist
- Handles multiple categories (comma-separated)
- Provides detailed error reporting
- Shows count of successful imports and errors

#### Import Members
```bash
rails csv:import_members FILENAME=members_to_import.csv
```
Imports members from the specified CSV file. The CSV file must be in the `tmp/` directory.

**Features:**
- Validates all member data according to model constraints
- Handles date parsing for birth and retirement dates
- Provides detailed error reporting
- Shows count of successful imports and errors

## Usage Examples

### Exporting Data
```bash
# Export all books with default filename
rails csv:export_books

# Export all members with custom filename
rails csv:export_members FILENAME=current_members.csv
```

### Importing Data
1. Place your CSV file in the `tmp/` directory
2. Ensure the CSV has the correct headers (see formats above)
3. Run the import task:

```bash
# Import books
rails csv:import_books FILENAME=new_books.csv

# Import members
rails csv:import_members FILENAME=new_members.csv
```

## File Location

- **Export files**: Generated in `tmp/` directory
- **Import files**: Must be placed in `tmp/` directory

## Error Handling

Both import tasks provide detailed error reporting:
- Shows total count of successful imports
- Shows count of errors
- Lists specific validation errors for failed rows
- Continues processing even if individual rows fail

## Sample CSV Files

Sample CSV files are available in the `tmp/` directory:
- `sample_books.csv` - Example book data format
- `sample_members.csv` - Example member data format