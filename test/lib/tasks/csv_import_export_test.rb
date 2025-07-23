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
    Member.create!(name: 'Test Member', personal_number: 12345, email: 'test@example.com', phone: '9998887777', section: 'IT', date_of_birth: Date.new(1990, 1, 1), date_of_retirement: Date.new(2025, 12, 31))
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
end
