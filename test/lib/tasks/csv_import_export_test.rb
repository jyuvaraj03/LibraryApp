# frozen_string_literal: true

require 'test_helper'
require 'csv'

class CsvImportExportTest < ActiveSupport::TestCase
  def setup
    @temp_dir = Rails.root.join('tmp')
    Dir.mkdir(@temp_dir) unless Dir.exist?(@temp_dir)
  end

  def teardown
    # Clean up test files
    Dir.glob(File.join(@temp_dir, '*test*.csv')).each do |file|
      File.delete(file)
    end
  end

  test 'books can be exported to CSV' do
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

    # Test CSV export structure
    csv_file = File.join(@temp_dir, 'books_test.csv')
    
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
        book.custom_number,
        book.name,
        book.publishing_year,
        book.author&.name,
        book.publisher&.name,
        book.categories.map(&:name).join(', ')
      ]
    end

    # Verify CSV content
    csv_data = CSV.read(csv_file, headers: true)
    assert_equal 1, csv_data.length
    assert_equal 'Test Book', csv_data.first['name']
    assert_equal 'Test Author', csv_data.first['author_name']
    assert_equal 'Test Publisher', csv_data.first['publisher_name']
    assert_equal 'Test Category', csv_data.first['category_names']
  end

  test 'books can be imported from CSV' do
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

    # Test import logic
    initial_book_count = Book.count
    initial_author_count = Author.count
    initial_publisher_count = Publisher.count
    initial_category_count = Category.count

    CSV.foreach(csv_file, headers: true) do |row|
      book_params = {
        custom_number: row['custom_number'],
        name: row['name'],
        publishing_year: row['publishing_year']&.to_i,
        author_name: row['author_name'],
        publisher_name: row['publisher_name'],
        category_names: row['category_names']
      }
      
      Book.create_with_associated_models(book_params)
    end

    assert_equal initial_book_count + 1, Book.count
    assert_equal initial_author_count + 1, Author.count
    assert_equal initial_publisher_count + 1, Publisher.count
    assert_equal initial_category_count + 2, Category.count # Fiction, Drama

    imported_book = Book.find_by(custom_number: 'IB001')
    assert_not_nil imported_book
    assert_equal 'Imported Book', imported_book.name
    assert_equal 'Import Author', imported_book.author.name
    assert_equal 'Import Publisher', imported_book.publisher.name
    assert_equal ['Fiction', 'Drama'], imported_book.categories.map(&:name).sort
  end

  test 'members can be exported to CSV' do
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

    # Test CSV export structure
    csv_file = File.join(@temp_dir, 'members_test.csv')
    
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
        member.custom_number,
        member.personal_number,
        member.name,
        member.tamil_name,
        member.email,
        member.phone,
        member.section,
        member.date_of_birth,
        member.date_of_retirement
      ]
    end

    # Verify CSV content
    csv_data = CSV.read(csv_file, headers: true)
    assert_equal 1, csv_data.length
    assert_equal 'Test Member', csv_data.first['name']
    assert_equal '12345', csv_data.first['personal_number']
    assert_equal 'test@example.com', csv_data.first['email']
  end

  test 'members can be imported from CSV' do
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

    # Test import logic
    initial_member_count = Member.count

    CSV.foreach(csv_file, headers: true) do |row|
      member_params = {
        custom_number: row['custom_number'],
        personal_number: row['personal_number']&.to_i,
        name: row['name'],
        tamil_name: row['tamil_name'],
        email: row['email'].presence,
        phone: row['phone'].presence,
        section: row['section'],
        date_of_birth: row['date_of_birth'].present? ? Date.parse(row['date_of_birth']) : nil,
        date_of_retirement: row['date_of_retirement'].present? ? Date.parse(row['date_of_retirement']) : nil
      }
      
      Member.create!(member_params)
    end

    assert_equal initial_member_count + 1, Member.count

    imported_member = Member.find_by(personal_number: 54321)
    assert_not_nil imported_member
    assert_equal 'Imported Member', imported_member.name
    assert_equal 'இறக்குமதி உறுப்பினர்', imported_member.tamil_name
    assert_equal 'imported@example.com', imported_member.email
    assert_equal Date.new(1985, 5, 15), imported_member.date_of_birth
  end
end