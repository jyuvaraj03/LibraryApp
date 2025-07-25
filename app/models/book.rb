# frozen_string_literal: true

class Book < ApplicationRecord
  # Model Column Definition
  # t.text "name"
  # t.integer "publishing_year"
  # t.bigint "author_id"
  # t.bigint "publisher_id"
  # t.datetime "created_at", precision: 6, null: false
  # t.datetime "updated_at", precision: 6, null: false
  # t.index ["author_id"], name: "index_books_on_author_id"
  # t.index ["publisher_id"], name: "index_books_on_publisher_id"

  include PgSearch::Model
  include Filterable

  include Searchable
  SEARCH_SCOPES = %i[search_by_id search_by_name]

  belongs_to :author, optional: true
  belongs_to :publisher, optional: true
  has_many :book_categories
  has_many :categories, through: :book_categories
  has_many :book_rentals

  attr_accessor :category_names

  validates :custom_number, uniqueness: true
  # TODO: Uncomment after migrating production data and writing seeds
  # validates :custom_number, presence: true
  validates :name, presence: true
  validates :publishing_year, numericality: { allow_nil: true, less_than_or_equal_to: Time.now.year }
  include CustomNumberAssignable

  def self.custom_number_column; :custom_number; end
  def self.custom_number_prefix; 'B'; end
  def self.custom_number_length; 6; end

  pg_search_scope :search_by_name,
                  against: %i[name],
                  associated_against: {
                    author: :name
                  },
                  using: {
                    tsearch: { prefix: true }
                  }

  # acts like a scope
  def self.available
    where.not(id: joins(:book_rentals).where(book_rentals: { returned_on: nil }))
  end

  def self.unavailable
    where(id: joins(:book_rentals).where(book_rentals: { returned_on: nil }))
  end

  def self.filter_by_availability(availability)
    case availability
    when 'true', true
      available
    when 'false', false
      unavailable
    else
      all
    end
  end

  def self.search_by_id(search_id)
    where(custom_number: search_id).or(where(id: search_id))
  end


  def self.create_with_associated_models(hash = {})
    Book.transaction do
      author = Author.find_or_create_by(name: hash[:author_name])
      publisher = Publisher.find_or_create_by(name: hash[:publisher_name])
      categories = hash[:category_names]&.split(',')&.map do |category_name|
        Category.find_or_create_by(name: category_name.strip)
      end&.compact || []


      @new_book = Book.create(custom_number: hash[:custom_number], name: hash[:name], author: author, publisher: publisher,
                              publishing_year: hash[:publishing_year], categories: categories)
      raise ActiveRecord::Rollback if @new_book.invalid?
    end
    @new_book
  end

  def available?
    !BookRental.exists?(book_id: id, returned_on: nil)
  end
end
