require "test_helper"

class BookRentalTest < ActiveSupport::TestCase
  test 'due_by should be equal to DUE_BY_DAYS + issued_on date' do
    issued_on = Date.today
    book_rental = BookRental.new(
      book: books(:unborrowed),
      member: members(:johnny),
      issued_on: issued_on
    )

    assert_equal issued_on + BookRental::DUE_BY_DAYS, book_rental.due_by
  end

  test 'fine should be zero if the book has already been returned' do
    book_rental = book_rentals(:returned)
    assert_equal 0, book_rental.fine
  end

  test 'fine should be zero if due_by is today or in future' do
    book_rental = BookRental.new(
      book: books(:unborrowed),
      member: members(:johnny),
      issued_on: Date.today # this ensures due_by will be in the future
    )
    assert_operator book_rental.due_by, :>, Date.today
    assert_equal 0, book_rental.fine

    book_rental.issued_on = Date.today - BookRental::DUE_BY_DAYS
    assert_equal Date.today, book_rental.due_by
    assert_equal 0, book_rental.fine
  end

  test 'fine should be equal to (returning_on - due_by) multiplied by FINE_PER_DAY' do
    returning_on = 2.days.ago.to_date
    days_elapsed_after_due_by = 5
    # e.g. issued_on = Today - (15 + 5)
    issued_on = returning_on - (BookRental::DUE_BY_DAYS + days_elapsed_after_due_by)
    book_rental = BookRental.new(
      book: books(:unborrowed),
      member: members(:johnny),
      issued_on: issued_on
    )

    assert_equal (returning_on - book_rental.due_by) * BookRental::FINE_PER_DAY, book_rental.fine(returning_on)
    assert book_rental.fine.instance_of? Float
  end

  test 'search should match book rental by book name' do
    book_rental = book_rentals(:unreturned)
    assert_includes BookRental.search(book_rental.book.name), book_rental
  end

  test 'search should match book rental by partial book name' do
    book_rental = book_rentals(:unreturned)
    assert_includes BookRental.search(book_rental.book.name[..-2]), book_rental
  end

  test 'search should match book rental by member name' do
    book_rental = book_rentals(:unreturned)
    assert_includes BookRental.search(book_rental.member.name), book_rental
  end

  test 'search should match book rental by partial member name' do
    book_rental = book_rentals(:unreturned)
    assert_includes BookRental.search(book_rental.member.name[..-2]), book_rental
  end

  test 'empty search query should return all book rentals' do
    search_results = BookRental.search('')
    assert_equal BookRental.all, search_results
  end

  test 'filter_by_show_all should return all rented out rentals when called with string "true"' do
    filter_results = BookRental.filter_by_show_all('true')
    assert_equal BookRental.all, filter_results
  end

  test 'filter_by_show_all should return all rented out rentals when called with boolean true' do
    filter_results = BookRental.filter_by_show_all(true)
    assert_equal BookRental.all, filter_results
  end

  test 'filter_by_show_all should return only current rentals when called with string "false"' do
    filter_results = BookRental.filter_by_show_all('false')
    assert_equal BookRental.current, filter_results
  end

  test 'filter_by_show_all should return all rentals when called with boolean true' do
    filter_results = BookRental.filter_by_show_all(true)
    assert_equal BookRental.all, filter_results
  end

  test 'filter_by_show_all should return only current rentals when called with blank values' do
    filter_results = BookRental.filter_by_show_all(nil)
    assert_equal BookRental.current, filter_results

    filter_results = BookRental.filter_by_show_all('')
    assert_equal BookRental.current, filter_results
  end

  test 'search_by_id should find by book custom_number' do
    book_rental = book_rentals(:returned)
    custom_number = book_rental.book.custom_number
    results = BookRental.search_by_id(custom_number)
    assert_includes results, book_rental
  end

  test 'search_by_id should find by member custom_number' do
    book_rental = book_rentals(:returned)
    custom_number = book_rental.member.custom_number
    results = BookRental.search_by_id(custom_number)
    assert_includes results, book_rental
  end
end
