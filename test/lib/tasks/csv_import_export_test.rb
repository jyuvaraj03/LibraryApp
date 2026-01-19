# frozen_string_literal: true

require 'test_helper'
require 'csv_import_export'

class CsvImportExportTest < ActiveSupport::TestCase
  def setup
    @temp_dir = Rails.root.join('tmp')
    BookRental.delete_all
    BookCategory.delete_all
    Book.delete_all
    Author.delete_all
    Publisher.delete_all
    Category.delete_all
    Member.delete_all
  end

  test 'export_books_to_csv writes correct data' do
    author = Author.create!(name: 'Test Author')
    publisher = Publisher.create!(name: 'Test Publisher')
    category = Category.create!(name: 'Test Category')
    Book.create!(name: 'Test Book', custom_number: 'TB001', publishing_year: 2023, author: author, publisher: publisher, categories: [category])
    filename = 'books_export_test.csv'
    filepath = CsvImportExport.export_books_to_csv(filename)
    assert File.exist?(filepath), 'CSV file should be created'
    csv_data = CSV.read(filepath, headers: true)
    assert_equal 1, csv_data.length
    assert_equal 'Test Book', csv_data.first['name']
    assert_equal 'Test Author', csv_data.first['author_name']
    assert_equal 'Test Publisher', csv_data.first['publisher_name']
    assert_equal 'Test Category', csv_data.first['category_names']
  ensure
    File.delete(filepath) if filepath && File.exist?(filepath)
  end

  test 'import_books_from_csv imports data and returns result hash' do
    filename = 'books_import_test.csv'
    csv_file = File.join(@temp_dir, filename)
    CSV.open(csv_file, 'w', headers: true) do |csv|
      csv << %w[custom_number name publishing_year author_name publisher_name category_names]
      csv << ['IB001', 'Imported Book', '2022', 'Import Author', 'Import Publisher', 'Fiction, Drama']
    end
    result = CsvImportExport.import_books_from_csv(filename)
    assert_equal 1, result[:success_count]
    assert_equal 0, result[:error_count]
    imported_book = Book.find_by(custom_number: 'IB001')
    assert_not_nil imported_book
    assert_equal 'Imported Book', imported_book.name
    assert_equal 'Import Author', imported_book.author.name
    assert_equal 'Import Publisher', imported_book.publisher.name
    assert_equal ['Fiction', 'Drama'], imported_book.categories.map(&:name)
  ensure
    File.delete(csv_file) if File.exist?(csv_file)
  end

  test 'export_members_to_csv writes correct data' do
    Member.create!(name: 'Test Member', personal_number: 12345, custom_number: 'M999999', email: 'test@example.com', phone: '9998887777', section: 'IT', date_of_birth: Date.new(1990, 1, 1), date_of_retirement: Date.new(2025, 12, 31))
    filename = 'members_export_test.csv'
    filepath = CsvImportExport.export_members_to_csv(filename)
    assert File.exist?(filepath), 'CSV file should be created'
    csv_data = CSV.read(filepath, headers: true)
    assert_equal 1, csv_data.length
    assert_equal 'Test Member', csv_data.first['name']
    assert_equal '12345', csv_data.first['personal_number']
    assert_equal 'test@example.com', csv_data.first['email']
  ensure
    File.delete(filepath) if filepath && File.exist?(filepath)
  end

  test 'import_members_from_csv imports data and returns result hash' do
    filename = 'members_import_test.csv'
    csv_file = File.join(@temp_dir, filename)
    CSV.open(csv_file, 'w', headers: true) do |csv|
      csv << %w[custom_number personal_number name tamil_name email phone section date_of_birth date_of_retirement]
      csv << ['IM001', '54321', 'Imported Member', 'இறக்குமதி உறுப்பினர்', 'imported@example.com', '0987654321', 'HR', '1985-05-15', '2030-12-31']
    end
    result = CsvImportExport.import_members_from_csv(filename)
    assert_equal 1, result[:success_count]
    assert_equal 0, result[:error_count]
    imported_member = Member.find_by(personal_number: 54321)
    assert_not_nil imported_member
    assert_equal 'Imported Member', imported_member.name
    assert_equal 'இறக்குமதி உறுப்பினர்', imported_member.tamil_name
    assert_equal 'imported@example.com', imported_member.email
    assert_equal Date.new(1985, 5, 15), imported_member.date_of_birth
  ensure
    File.delete(csv_file) if File.exist?(csv_file)
  end

  test 'import_books_from_csv returns errors for invalid data' do
    filename = 'books_import_invalid_test.csv'
    csv_file = File.join(@temp_dir, filename)
    CSV.open(csv_file, 'w', headers: true) do |csv|
      csv << %w[custom_number name publishing_year author_name publisher_name category_names]
      csv << ['', '', 'invalid_year', 'Author', 'Publisher', 'Category']
    end
    result = CsvImportExport.import_books_from_csv(filename)
    assert_equal 0, result[:success_count]
    assert_equal 1, result[:error_count]
    assert result[:errors].any?
  ensure
    File.delete(csv_file) if File.exist?(csv_file)
  end

  test 'import_members_from_csv upserts existing member' do
    # Create initial member
    member = Member.create!(custom_number: 'IM002', personal_number: 11111, name: 'Original Name', tamil_name: 'மூல உறுப்பினர்', email: 'orig@example.com', phone: '1234567890', section: 'Finance', date_of_birth: Date.new(1980, 1, 1), date_of_retirement: Date.new(2030, 1, 1))
    filename = 'members_import_upsert_test.csv'
    csv_file = File.join(@temp_dir, filename)
    CSV.open(csv_file, 'w', headers: true) do |csv|
      csv << %w[custom_number personal_number name tamil_name email phone section date_of_birth date_of_retirement]
      csv << ['IM002', '22222', 'Updated Name', 'புதுப்பிக்கப்பட்ட உறுப்பினர்', 'updated@example.com', '0987654321', 'Legal', '1981-02-02', '2031-02-02']
    end
    result = CsvImportExport.import_members_from_csv(filename)
    assert_equal 1, result[:success_count]
    member.reload
    assert_equal 'Updated Name', member.name
    assert_equal 'புதுப்பிக்கப்பட்ட உறுப்பினர்', member.tamil_name
    assert_equal 'updated@example.com', member.email
    assert_equal '0987654321', member.phone
    assert_equal 'Legal', member.section
    assert_equal Date.new(1981, 2, 2), member.date_of_birth
    assert_equal Date.new(2031, 2, 2), member.date_of_retirement
  ensure
    File.delete(csv_file) if File.exist?(csv_file)
  end

  test 'import_members_from_csv inserts new member if custom_number does not exist' do
    filename = 'members_import_new_test.csv'
    csv_file = File.join(@temp_dir, filename)
    CSV.open(csv_file, 'w', headers: true) do |csv|
      csv << %w[custom_number personal_number name tamil_name email phone section date_of_birth date_of_retirement]
      csv << ['IM003', '33333', 'New Member', 'புதிய உறுப்பினர்', 'new@example.com', '1231231234', 'Admin', '1995-03-03', '2040-03-03']
    end
    result = CsvImportExport.import_members_from_csv(filename)
    assert_equal 1, result[:success_count]
    member = Member.find_by(custom_number: 'IM003')
    assert_not_nil member
    assert_equal 'New Member', member.name
    assert_equal 'புதிய உறுப்பினர்', member.tamil_name
    assert_equal 'new@example.com', member.email
    assert_equal '1231231234', member.phone
    assert_equal 'Admin', member.section
    assert_equal Date.new(1995, 3, 3), member.date_of_birth
    assert_equal Date.new(2040, 3, 3), member.date_of_retirement
  ensure
    File.delete(csv_file) if File.exist?(csv_file)
  end
  test 'import_books_from_csv with dry_run does not persist data' do
    filename = 'books_import_dry_run_test.csv'
    csv_file = File.join(@temp_dir, filename)
    CSV.open(csv_file, 'w', headers: true) do |csv|
      csv << %w[custom_number name publishing_year author_name publisher_name category_names]
      csv << ['IB999', 'Dry Run Book', '2023', 'Dry Author', 'Dry Publisher', 'Dry Category']
    end

    assert_no_difference 'Book.count' do
      result = CsvImportExport.import_books_from_csv(filename, dry_run: true)
      assert_equal 1, result[:success_count]
      assert_equal 0, result[:error_count]
    end

    assert_nil Book.find_by(custom_number: 'IB999')
  ensure
    File.delete(csv_file) if File.exist?(csv_file)
  end

  test 'import_members_from_csv with dry_run does not persist data' do
    filename = 'members_import_dry_run_test.csv'
    csv_file = File.join(@temp_dir, filename)
    CSV.open(csv_file, 'w', headers: true) do |csv|
      csv << %w[custom_number personal_number name tamil_name email phone section date_of_birth date_of_retirement]
      csv << ['IM999', '99999', 'Dry Member', 'உலர்ந்த உறுப்பினர்', 'dry@example.com', '1234567890', 'Dry', '1990-01-01', '2030-01-01']
    end

    assert_no_difference 'Member.count' do
      result = CsvImportExport.import_members_from_csv(filename, dry_run: true)
      assert_equal 1, result[:success_count]
      assert_equal 0, result[:error_count]
    end

    assert_nil Member.find_by(custom_number: 'IM999')
  ensure
    File.delete(csv_file) if File.exist?(csv_file)
  end
end
