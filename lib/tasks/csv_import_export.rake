# frozen_string_literal: true

require 'csv'

namespace :csv do
  desc 'Export all books to CSV'
  task export_books: :environment do
    filename = ENV['FILENAME'] || "books_export_#{Time.current.strftime('%Y%m%d_%H%M%S')}.csv"
    filepath = Rails.root.join('tmp', filename)
    
    puts "Exporting books to #{filepath}..."
    
    CSV.open(filepath, 'w', headers: true) do |csv|
      # CSV Headers
      csv << [
        'custom_number',
        'name', 
        'publishing_year',
        'author_name',
        'publisher_name',
        'category_names'
      ]
      
      Book.includes(:author, :publisher, :categories).find_each do |book|
        csv << [
          book.custom_number,
          book.name,
          book.publishing_year,
          book.author&.name,
          book.publisher&.name,
          book.categories.map(&:name).join(', ')
        ]
      end
    end
    
    book_count = Book.count
    puts "Successfully exported #{book_count} books to #{filepath}"
  end

  desc 'Import books from CSV'
  task import_books: :environment do
    filename = ENV['FILENAME'] || raise('Please specify FILENAME environment variable')
    filepath = Rails.root.join('tmp', filename)
    
    unless File.exist?(filepath)
      puts "Error: File #{filepath} does not exist"
      exit 1
    end
    
    puts "Importing books from #{filepath}..."
    
    success_count = 0
    error_count = 0
    errors = []
    
    CSV.foreach(filepath, headers: true) do |row|
      book_params = {
        custom_number: row['custom_number'],
        name: row['name'],
        publishing_year: row['publishing_year']&.to_i,
        author_name: row['author_name'],
        publisher_name: row['publisher_name'],
        category_names: row['category_names']
      }
      
      book = Book.create_with_associated_models(book_params)
      
      if book.persisted? && book.valid?
        success_count += 1
      else
        error_count += 1
        errors << "Row #{$.}: #{book.errors.full_messages.join(', ')}"
      end
    end
    
    puts "Import completed: #{success_count} books imported successfully, #{error_count} errors"
    
    if errors.any?
      puts "\nErrors:"
      errors.each { |error| puts "  #{error}" }
    end
  end

  desc 'Export all members to CSV'
  task export_members: :environment do
    filename = ENV['FILENAME'] || "members_export_#{Time.current.strftime('%Y%m%d_%H%M%S')}.csv"
    filepath = Rails.root.join('tmp', filename)
    
    puts "Exporting members to #{filepath}..."
    
    CSV.open(filepath, 'w', headers: true) do |csv|
      # CSV Headers
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
      
      Member.find_each do |member|
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
    end
    
    member_count = Member.count
    puts "Successfully exported #{member_count} members to #{filepath}"
  end

  desc 'Import members from CSV'
  task import_members: :environment do
    filename = ENV['FILENAME'] || raise('Please specify FILENAME environment variable')
    filepath = Rails.root.join('tmp', filename)
    
    unless File.exist?(filepath)
      puts "Error: File #{filepath} does not exist"
      exit 1
    end
    
    puts "Importing members from #{filepath}..."
    
    success_count = 0
    error_count = 0
    errors = []
    
    CSV.foreach(filepath, headers: true) do |row|
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
      
      member = Member.new(member_params)
      
      if member.save
        success_count += 1
      else
        error_count += 1
        errors << "Row #{$.}: #{member.errors.full_messages.join(', ')}"
      end
    end
    
    puts "Import completed: #{success_count} members imported successfully, #{error_count} errors"
    
    if errors.any?
      puts "\nErrors:"
      errors.each { |error| puts "  #{error}" }
    end
  end
end