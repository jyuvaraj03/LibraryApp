#!/usr/bin/env ruby
# frozen_string_literal: true

# CSV Import/Export CLI Script for LibraryApp
# This script provides CSV import/export functionality without requiring the full Rails environment
# Usage: ruby script/csv_cli.rb [export|import] [books|members] [filename]

require 'csv'
require 'optparse'

class CSVCli
  def initialize
    @options = {}
    @parser = OptionParser.new do |opts|
      opts.banner = "Usage: #{$0} [export|import] [books|members] [filename]"
      opts.on("-h", "--help", "Show this help") { puts opts; exit }
    end
  end

  def run(args)
    @parser.parse!(args) rescue (puts @parser; exit 1)
    
    if args.length < 2
      puts @parser
      exit 1
    end

    action = args[0]
    entity = args[1]
    filename = args[2]

    case action
    when 'export'
      export(entity, filename)
    when 'import'
      import(entity, filename)
    else
      puts "Unknown action: #{action}"
      puts @parser
      exit 1
    end
  end

  private

  def export(entity, filename = nil)
    case entity
    when 'books'
      export_books(filename)
    when 'members'
      export_members(filename)
    else
      puts "Unknown entity: #{entity}. Use 'books' or 'members'"
      exit 1
    end
  end

  def import(entity, filename)
    unless filename
      puts "Filename required for import"
      exit 1
    end

    case entity
    when 'books'
      import_books(filename)
    when 'members'
      import_members(filename)
    else
      puts "Unknown entity: #{entity}. Use 'books' or 'members'"
      exit 1
    end
  end

  def export_books(filename = nil)
    filename ||= "books_export_#{Time.now.strftime('%Y%m%d_%H%M%S')}.csv"
    filepath = File.join('tmp', filename)
    
    puts "Exporting sample books to #{filepath}..."
    
    CSV.open(filepath, 'w', headers: true) do |csv|
      csv << [
        'custom_number',
        'name',
        'publishing_year',
        'author_name',
        'publisher_name',
        'category_names'
      ]
      
      # Sample data
      csv << ['B001', 'The Ruby Way', '2020', 'Ruby Author', 'Tech Publications', 'Programming, Education']
      csv << ['B002', 'Rails Guide', '2021', 'Rails Master', 'Web Publishers', 'Web Development, Framework']
      csv << ['B003', 'Database Design', '2019', 'DB Expert', 'Data Press', 'Database, Design']
    end
    
    puts "Sample books exported to #{filepath}"
  end

  def export_members(filename = nil)
    filename ||= "members_export_#{Time.now.strftime('%Y%m%d_%H%M%S')}.csv"
    filepath = File.join('tmp', filename)
    
    puts "Exporting sample members to #{filepath}..."
    
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
      
      # Sample data
      csv << ['M001', '1001', 'John Doe', 'ஜான் டோ', 'john@example.com', '1234567890', 'IT', '1985-01-15', '2025-12-31']
      csv << ['M002', '1002', 'Jane Smith', 'ஜேன் ஸ்மித்', 'jane@example.com', '2345678901', 'HR', '1990-05-20', '2030-06-30']
      csv << ['M003', '1003', 'Bob Johnson', 'பாப் ஜான்சன்', 'bob@example.com', '3456789012', 'Finance', '1988-12-10', '2028-11-15']
    end
    
    puts "Sample members exported to #{filepath}"
  end

  def import_books(filename)
    filepath = File.join('tmp', filename)
    
    unless File.exist?(filepath)
      puts "Error: File #{filepath} does not exist"
      exit 1
    end
    
    puts "Importing books from #{filepath}..."
    
    success_count = 0
    error_count = 0
    errors = []
    
    CSV.foreach(filepath, headers: true) do |row|
      # Validate required fields
      if row['name'].nil? || row['name'].strip.empty?
        error_count += 1
        errors << "Row #{$.}: Book name is required"
        next
      end
      
      # Simulate book creation validation
      puts "Processing book: #{row['name']} by #{row['author_name']}"
      success_count += 1
    end
    
    puts "Import completed: #{success_count} books processed, #{error_count} errors"
    
    if errors.any?
      puts "\nErrors:"
      errors.each { |error| puts "  #{error}" }
    end
  end

  def import_members(filename)
    filepath = File.join('tmp', filename)
    
    unless File.exist?(filepath)
      puts "Error: File #{filepath} does not exist"
      exit 1
    end
    
    puts "Importing members from #{filepath}..."
    
    success_count = 0
    error_count = 0
    errors = []
    
    CSV.foreach(filepath, headers: true) do |row|
      # Validate required fields
      if row['name'].nil? || row['name'].strip.empty?
        error_count += 1
        errors << "Row #{$.}: Member name is required"
        next
      end
      
      if row['personal_number'].nil? || row['personal_number'].strip.empty?
        error_count += 1
        errors << "Row #{$.}: Personal number is required"
        next
      end
      
      # Simulate member creation validation
      puts "Processing member: #{row['name']} (#{row['personal_number']})"
      success_count += 1
    end
    
    puts "Import completed: #{success_count} members processed, #{error_count} errors"
    
    if errors.any?
      puts "\nErrors:"
      errors.each { |error| puts "  #{error}" }
    end
  end
end

# Create tmp directory if it doesn't exist
Dir.mkdir('tmp') unless Dir.exist?('tmp')

# Run the CLI
CSVCli.new.run(ARGV)