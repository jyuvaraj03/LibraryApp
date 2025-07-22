# frozen_string_literal: true

require 'test_helper'
require 'csv'
require 'rake'

class CsvImportExportTest < ActiveSupport::TestCase
  def setup
    @temp_dir = Rails.root.join('tmp')
    Dir.mkdir(@temp_dir) unless Dir.exist?(@temp_dir)
    
    # Load rake tasks
    Rails.application.load_tasks if Rake::Task.tasks.empty?
  end

  def teardown
    # Clean up test files
    Dir.glob(File.join(@temp_dir, '*test*.csv')).each do |file|
      File.delete(file)
    end
  end

  test 'csv:export_books rake task creates CSV file with book data' do
    # Create test data
    author = Author.create!(name: 'Test Author')
    publisher = Publisher.create!(name: 'Test Publisher')
    category = Category.create!(name: 'Test Category')
    
    book = Book.create!(
      name: 'Test Book',
      custom_number: 'TB001',
      publishing_year: 2023,
      author: author,
      publisher: publisher,
      categories: [category]
    )

    # Run the rake task with custom filename
    ENV['FILENAME'] = 'books_export_test.csv'
    
    # Capture output to avoid printing during tests
    output = capture(:stdout) do
      Rake::Task['csv:export_books'].invoke
    end
    
    # Check that the CSV file was created
    csv_file = File.join(@temp_dir, 'books_export_test.csv')
    assert File.exist?(csv_file), "CSV file should be created"
    
    # Verify CSV content
    csv_data = CSV.read(csv_file, headers: true)
    assert_equal 1, csv_data.length
    assert_equal 'Test Book', csv_data.first['name']
    assert_equal 'Test Author', csv_data.first['author_name']
    assert_equal 'Test Publisher', csv_data.first['publisher_name']
    assert_equal 'Test Category', csv_data.first['category_names']
    
    # Verify output message
    assert_match(/Successfully exported 1 books/, output)
    
    # Clean up
    ENV.delete('FILENAME')
    Rake::Task['csv:export_books'].reenable
  end

  test 'csv:import_books rake task imports books from CSV file' do
    # Create test CSV file
    csv_file = File.join(@temp_dir, 'books_import_test.csv')
    
    CSV.open(csv_file, 'w', headers: true) do |csv|
      csv << [
        'custom_number',
        'name', 
        'publishing_year',
        'author_name',
        'publisher_name',
        'category_names'
      ]
      
      csv << [
        'IB001',
        'Imported Book',
        '2022',
        'Import Author',
        'Import Publisher',
        'Fiction, Drama'
      ]
    end

    # Store initial counts
    initial_book_count = Book.count
    initial_author_count = Author.count
    initial_publisher_count = Publisher.count
    initial_category_count = Category.count

    # Run the rake task
    ENV['FILENAME'] = 'books_import_test.csv'
    
    output = capture(:stdout) do
      Rake::Task['csv:import_books'].invoke
    end

    # Verify counts increased
    assert_equal initial_book_count + 1, Book.count
    assert_equal initial_author_count + 1, Author.count
    assert_equal initial_publisher_count + 1, Publisher.count
    assert_equal initial_category_count + 2, Category.count # Fiction, Drama

    # Verify imported book data
    imported_book = Book.find_by(custom_number: 'IB001')
    assert_not_nil imported_book
    assert_equal 'Imported Book', imported_book.name
    assert_equal 'Import Author', imported_book.author.name
    assert_equal 'Import Publisher', imported_book.publisher.name
    assert_equal ['Fiction', 'Drama'], imported_book.categories.map(&:name).sort
    
    # Verify output message
    assert_match(/Import completed: 1 books imported successfully/, output)
    
    # Clean up
    ENV.delete('FILENAME')
    Rake::Task['csv:import_books'].reenable
  end

  test 'csv:export_members rake task creates CSV file with member data' do
    # Create test data
    member = Member.create!(
      name: 'Test Member',
      personal_number: 12345,
      email: 'test@example.com',
      phone: '1234567890',
      section: 'IT',
      date_of_birth: Date.new(1990, 1, 1),
      date_of_retirement: Date.new(2025, 12, 31)
    )

    # Run the rake task with custom filename
    ENV['FILENAME'] = 'members_export_test.csv'
    
    output = capture(:stdout) do
      Rake::Task['csv:export_members'].invoke
    end
    
    # Check that the CSV file was created
    csv_file = File.join(@temp_dir, 'members_export_test.csv')
    assert File.exist?(csv_file), "CSV file should be created"
    
    # Verify CSV content
    csv_data = CSV.read(csv_file, headers: true)
    assert_equal 1, csv_data.length
    assert_equal 'Test Member', csv_data.first['name']
    assert_equal '12345', csv_data.first['personal_number']
    assert_equal 'test@example.com', csv_data.first['email']
    
    # Verify output message
    assert_match(/Successfully exported 1 members/, output)
    
    # Clean up
    ENV.delete('FILENAME')
    Rake::Task['csv:export_members'].reenable
  end

  test 'csv:import_members rake task imports members from CSV file' do
    # Create test CSV file
    csv_file = File.join(@temp_dir, 'members_import_test.csv')
    
    CSV.open(csv_file, 'w', headers: true) do |csv|
      csv << [
        'custom_number',
        'personal_number',
        'name',
        'tamil_name',
        'email',
        'phone',
        'section',
        'date_of_birth',
        'date_of_retirement'
      ]
      
      csv << [
        'IM001',
        '54321',
        'Imported Member',
        'இறக்குமதி உறுப்பினர்',
        'imported@example.com',
        '0987654321',
        'HR',
        '1985-05-15',
        '2030-12-31'
      ]
    end

    # Store initial count
    initial_member_count = Member.count

    # Run the rake task
    ENV['FILENAME'] = 'members_import_test.csv'
    
    output = capture(:stdout) do
      Rake::Task['csv:import_members'].invoke
    end

    # Verify count increased
    assert_equal initial_member_count + 1, Member.count

    # Verify imported member data
    imported_member = Member.find_by(personal_number: 54321)
    assert_not_nil imported_member
    assert_equal 'Imported Member', imported_member.name
    assert_equal 'இறக்குமதி உறுப்பினர்', imported_member.tamil_name
    assert_equal 'imported@example.com', imported_member.email
    assert_equal Date.new(1985, 5, 15), imported_member.date_of_birth
    
    # Verify output message
    assert_match(/Import completed: 1 members imported successfully/, output)
    
    # Clean up
    ENV.delete('FILENAME')
    Rake::Task['csv:import_members'].reenable
  end
  
  test 'csv:import_books handles invalid data gracefully' do
    # Create test CSV file with invalid data
    csv_file = File.join(@temp_dir, 'books_import_invalid_test.csv')
    
    CSV.open(csv_file, 'w', headers: true) do |csv|
      csv << [
        'custom_number',
        'name', 
        'publishing_year',
        'author_name',
        'publisher_name',
        'category_names'
      ]
      
      csv << [
        '',  # Missing required custom_number
        '',  # Missing required name
        'invalid_year',
        'Author',
        'Publisher',
        'Category'
      ]
    end

    # Store initial count
    initial_book_count = Book.count

    # Run the rake task
    ENV['FILENAME'] = 'books_import_invalid_test.csv'
    
    output = capture(:stdout) do
      Rake::Task['csv:import_books'].invoke
    end

    # Verify no books were imported due to validation errors
    assert_equal initial_book_count, Book.count
    
    # Verify error reporting
    assert_match(/1 errors/, output)
    
    # Clean up
    ENV.delete('FILENAME')
    Rake::Task['csv:import_books'].reenable
  end
end