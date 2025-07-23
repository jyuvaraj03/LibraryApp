class Member < ApplicationRecord
  # Model Column Definition
  # t.string "name"
  # t.string "tamil_name"
  # t.integer "personal_number"
  # t.date "date_of_birth"
  # t.date "date_of_retirement"
  # t.string "email"
  # t.string "phone"
  # t.datetime "created_at", precision: 6, null: false
  # t.datetime "updated_at", precision: 6, null: false
  # t.string "section"
  # t.index ["email"], name: "index_members_on_email", unique: true
  # t.index ["personal_number"], name: "index_members_on_personal_number", unique: true
  # t.index ["phone"], name: "index_members_on_phone", unique: true

  include PgSearch::Model
  include Filterable

  include Searchable
  SEARCH_SCOPES = %i[search_by_id search_by_name]

  has_many :book_rentals

  validates :name, presence: true
  validates :personal_number, presence: true, uniqueness: true, numericality: { greater_than: 0 }

  include CustomNumberAssignable

  def self.custom_number_column; :custom_number; end
  def self.custom_number_prefix; 'M'; end
  def self.custom_number_length; 6; end

  validates :phone, length: { is: 10 }, uniqueness: true, allow_blank: true

  pg_search_scope :search_by_name,
                  against: %i[name tamil_name],
                  using: {
                    tsearch: { prefix: true }
                  }

  # filter only members who have less than the maximum allowed current book rentals
  scope :can_rent, -> { where( id: joins('LEFT JOIN book_rentals ON members.id = book_rentals.member_id AND book_rentals.returned_on IS NULL').group('members.id').having("COUNT(book_rentals.id) < #{BookRental::MAX_RENTALS} OR COUNT(book_rentals.id) IS NULL").merge(BookRental.current) ) }

  def self.search_by_id(search_id)
    Member.where(custom_number: search_id).or(Member.where(personal_number: search_id))
  end

  def self.filter_by_can_rent(filter_can_rent = false)
    case filter_can_rent
    when 'true', true
      can_rent
    else
      all
    end
  end

end
