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
  has_many :current_book_rentals, -> { current }, class_name: 'BookRental'

  attr_accessor :category_names, :author_name, :publisher_name

  validates :custom_number, uniqueness: true
  # TODO: Uncomment after migrating production data and writing seeds
  # validates :custom_number, presence: true
  validates :name, presence: true
  validates :publishing_year, numericality: { allow_nil: true, less_than_or_equal_to: Time.now.year }
  validates :custom_number, presence: true, uniqueness: true
  validates :price, numericality: { allow_nil: true, greater_than_or_equal_to: 0 }

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
    upsert_or_create_with_associated_models(hash, :create)
  end

  def self.upsert_with_associated_models(hash = {})
    upsert_or_create_with_associated_models(hash, :upsert)
  end

  def update_with_associated_models(hash = {})
    self.class.update_with_associated_models(self, hash)
  end

  def available?
    return current_book_rentals.empty? if association(:current_book_rentals).loaded?

    !BookRental.exists?(book_id: id, returned_on: nil)
  end

  private

  def self.update_with_associated_models(book, hash = {})
    Book.transaction do
      apply_associated_model_attributes(book, hash)
      raise ActiveRecord::Rollback if book.invalid?
    end
    book
  end

  def self.upsert_or_create_with_associated_models(hash, mode)
    book = nil
    Book.transaction do
      book =
        if mode == :upsert
          Book.find_or_initialize_by(custom_number: hash[:custom_number])
        else
          Book.new(custom_number: hash[:custom_number])
        end
      apply_associated_model_attributes(book, hash)
      raise ActiveRecord::Rollback if book.invalid?
    end
    book
  end

  def self.apply_associated_model_attributes(book, hash)
    book.update(name: hash[:name], author: find_associated_record(Author, hash[:author_name]),
                publisher: find_associated_record(Publisher, hash[:publisher_name]),
                publishing_year: hash[:publishing_year], categories: associated_categories(hash[:category_names]),
                price: hash[:price])
  end

  def self.find_associated_record(klass, name)
    return nil if name.blank?

    klass.find_or_initialize_by(name: name)
  end

  def self.associated_categories(category_names)
    return Category.none if category_names.blank?

    category_names.split(',').filter_map do |category_name|
      name = category_name.strip
      Category.find_or_initialize_by(name: name) if name.present?
    end
  end
end
