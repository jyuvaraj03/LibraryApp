class BookRental < ApplicationRecord
  # Model Column Definition
  # t.bigint "book_id", null: false
  # t.bigint "member_id", null: false
  # t.date "issued_on", default: -> { "CURRENT_TIMESTAMP" }
  # t.date "returned_on"
  # t.datetime "created_at", precision: 6, null: false
  # t.datetime "updated_at", precision: 6, null: false
  # t.index ["book_id"], name: "index_book_rentals_on_book_id"
  # t.index ["member_id"], name: "index_book_rentals_on_member_id"

  include Filterable

  include PgSearch::Model

  DUE_BY_DAYS = 15
  FINE_PER_DAY = 1
  MAX_RENTALS = 2

  belongs_to :book
  belongs_to :member

  before_validation :set_default_issued_on, on: :create

  validate :book_is_available, :member_has_only_max_rentals, on: :create

  scope :current, -> { where(returned_on: nil) }

  pg_search_scope :search_by_name,
                  associated_against: {
                    book: :name,
                    member: :name
                  },
                  using: {
                    tsearch: { prefix: true }
                  }

  def self.search(query, max_results=nil)
    if /^\d+$/.match(query.to_s)
      search_by_id(query).limit(max_results)
    elsif query.present?
      search_by_name(query).limit(max_results)
    else
      all.limit(max_results)
    end
  end

  # TODO: This is broken. It should search by custom number. Change after knowing custom_number pattern
  def self.search_by_id(search_id)
    where(book_id: search_id).or(where(member_id: search_id))
  end

  def self.filter_by_show_all(show_all)
    case show_all
    when 'true', true
      all
    else
      current
    end
  end

  def borrower_name_id
    "#{member.name} ##{member.id}"
  end

  def borrower_phone
    member.phone
  end

  def borrowed_book
    "#{book.name} ##{book.id}"
  end

  def returned?
    !returned_on.nil?
  end

  def due_by
    issued_on + DUE_BY_DAYS.days
  end

  def fine(returned_on = Date.today)
    if returned? || due_by >= returned_on
      0
    else
      ((returned_on - due_by) * FINE_PER_DAY).to_f
    end
  end

  private

  def set_default_issued_on
    self.issued_on ||= Date.today
  end

  def book_is_available
    return false if book.nil?
    errors.add(:base, I18n.t('book_not_available')) unless book.available?
  end

  def member_has_only_max_rentals
    errors.add(:member, I18n.t('member_borrowed_max_books')) if member.book_rentals.current.count >= MAX_RENTALS
  end
end
