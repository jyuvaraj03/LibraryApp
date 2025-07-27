# frozen_string_literal: true

require 'csv'

module CsvImportExport
  module_function

  def export_books_to_csv(filename = nil)
    filename ||= "books_export_#{Time.current.strftime('%Y%m%d_%H%M%S')}.csv"
    filepath = Rails.root.join('tmp', filename)
    CSV.open(filepath, 'w', headers: true) do |csv|
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
    filepath
  end

  def import_books_from_csv(filename)
    filepath = Rails.root.join('tmp', filename)
    raise "File #{filepath} does not exist" unless File.exist?(filepath)
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
    { success_count: success_count, error_count: error_count, errors: errors }
  end

  def export_members_to_csv(filename = nil)
    filename ||= "members_export_#{Time.current.strftime('%Y%m%d_%H%M%S')}.csv"
    filepath = Rails.root.join('tmp', filename)
    CSV.open(filepath, 'w', headers: true) do |csv|
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
    filepath
  end

  def import_members_from_csv(filename)
    filepath = Rails.root.join('tmp', filename)
    raise "File #{filepath} does not exist" unless File.exist?(filepath)
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
    { success_count: success_count, error_count: error_count, errors: errors }
  end
end
