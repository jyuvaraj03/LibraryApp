# frozen_string_literal: true

require 'csv'

require_relative '../../lib/csv_import_export'

namespace :csv do
  desc 'Export all books to CSV'
  task export_books: :environment do
    filename = ENV['FILENAME']
    filepath = CsvImportExport.export_books_to_csv(filename)
    book_count = Book.count
    puts "Successfully exported #{book_count} books to #{filepath}"
  end

  desc 'Import books from CSV'
  task import_books: :environment do
    filename = ENV['FILENAME'] || raise('Please specify FILENAME environment variable')
    begin
      dry_run = ENV['DRY_RUN'] == 'true'
      result = CsvImportExport.import_books_from_csv(filename, dry_run: dry_run)
      puts "Import completed: #{result[:success_count]} books imported successfully, #{result[:error_count]} errors, #{result[:updated_count]} updated"
      if result[:errors].any?
        puts "\nErrors:"
        result[:errors].each { |error| puts "  #{error}" }
      end
    rescue => e
      puts "Error: #{e.message}"
      exit 1
    end
  end

  desc 'Export all members to CSV'
  task export_members: :environment do
    filename = ENV['FILENAME']
    filepath = CsvImportExport.export_members_to_csv(filename, date_format)
    member_count = Member.count
    puts "Successfully exported #{member_count} members to #{filepath}"
  end

  desc 'Import members from CSV'
  task import_members: :environment do
    filename = ENV['FILENAME'] || raise('Please specify FILENAME environment variable')
    date_format = ENV['DATE_FORMAT'] || '%Y-%m-%d' # Refer: https://ruby-doc.org/stdlib-2.1.2/libdoc/date/rdoc/Date.html#method-c-strptime
    begin
      dry_run = ENV['DRY_RUN'] == 'true'
      result = CsvImportExport.import_members_from_csv(filename, date_format, dry_run: dry_run)
      puts "Import completed: #{result[:success_count]} members imported successfully, #{result[:error_count]} errors, #{result[:updated_count]} updated"
      if result[:errors].any?
        puts "\nErrors:"
        result[:errors].each { |error| puts "  #{error}" }
      end
    rescue => e
      puts "Error: #{e.message}"
      exit 1
    end
  end
end
