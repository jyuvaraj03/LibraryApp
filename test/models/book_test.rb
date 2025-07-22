# frozen_string_literal: true

require 'test_helper'

class BookTest < ActiveSupport::TestCase
  def setup
    @author = Author.create(name: 'Chetan Bhagat')
    @category1 = Category.create(name: 'Romance')
    @category2 = Category.create(name: 'Young Adult')
    @publisher = Publisher.create(name: 'Kalki')

    @book_name = 'The Shining'
    @author_name = 'Sidney Sheldon'
    @publisher_name = 'Rosetta Publications'
    @publishing_year = 2002
    @categories = 'Trauma, Women'
  end

  test 'should be valid' do
    book = Book.new(
      name: 'New Book',
      publishing_year: 2019,
      author: @author,
      categories: [@category1, @category2],
      publisher: @publisher
    )
    assert book.valid?
  end

  test 'should not have blank name' do
    book = books(:oliver_twist)
    assert book.valid?

    book.name = ''
    assert book.invalid?
  end

  test 'publishing year can be blank' do
    book = books(:oliver_twist)
    assert book.valid?

    book.publishing_year = nil
    assert book.valid?

    book.publishing_year = ''
    assert book.valid?
  end

  test 'publishing year should be less than or equal to current year' do
    book = books(:oliver_twist)
    assert book.valid?

    book.publishing_year = Date.today.year.succ
    assert book.invalid?

    book.publishing_year = Date.today.year
    assert book.valid?

    book.publishing_year = Date.today.year.pred
    assert book.valid?
  end

  test 'can be without an author' do
    book = books(:oliver_twist)
    assert book.valid?

    book.author = nil
    assert book.valid?
  end

  test 'can have zero categories' do
    book = books(:oliver_twist)
    assert book.valid?

    book.categories = []
    assert book.valid?
  end

  test 'can be without a publisher' do
    book = books(:oliver_twist)
    assert book.valid?

    book.publisher = nil
    assert book.valid?
  end

  test 'can create with associated models' do
    assert_difference -> { Book.count } => 1, -> { Author.count } => 1, -> { Publisher.count } => 1,
                      -> { Category.count } => 2 do
      book = Book.create_with_associated_models(name: @book_name, author_name: @author_name,
                                                publisher_name: @publisher_name, publishing_year: @publishing_year,
                                                category_names: @categories)
      assert book.valid?
      assert_equal book.name, @book_name
      assert_equal book.author.name, @author_name
      assert_equal book.publisher.name, @publisher_name
      assert_equal book.publishing_year, @publishing_year
      assert_includes @categories, book.categories.first.name
      assert_includes @categories, book.categories.second.name
    end
  end

  test 'cannot create with associated models when book name is missing' do
    book = Book.create_with_associated_models(name: nil, author_name: @author_name,
                                              publisher_name: @publisher_name, publishing_year: @publishing_year,
                                              category_names: @categories)
    assert book.invalid?
  end

  test 'can create with associated models when author name is missing' do
    book = Book.create_with_associated_models(name: @book_name, author_name: nil,
                                              publisher_name: @publisher_name, publishing_year: @publishing_year,
                                              category_names: @categories)
    book.reload
    assert book.valid?
    assert_nil book.author
  end

  test 'can create with associated models when publisher name is missing' do
    book = Book.create_with_associated_models(name: @book_name, author_name: @author_name,
                                              publisher_name: nil, publishing_year: @publishing_year,
                                              category_names: @categories)
    assert book.valid?
  end

  test 'can create with associated models when publishing year is missing' do
    book = Book.create_with_associated_models(name: @book_name, author_name: @author_name,
                                              publisher_name: @publisher_name, publishing_year: nil,
                                              category_names: @categories)
    assert book.valid?
  end

  test 'can create with associated models when categories is missing' do
    book = Book.create_with_associated_models(name: @book_name, author_name: @author_name,
                                              publisher_name: @publisher_name, publishing_year: nil,
                                              category_names: nil)
    assert book.valid?
  end

  test 'new author is not created when author_name is given as existing author name' do
    existing_author_name = @author.name
    assert_difference -> { Book.count } => 1, -> { Author.count } => 0 do
      book = Book.create_with_associated_models(name: @book_name, author_name: existing_author_name,
                                                publisher_name: @publisher_name, publishing_year: nil,
                                                category_names: nil)
      assert_equal book.author.name, existing_author_name
      assert book.valid?
    end
  end

  test 'new publisher is not created when publisher_name is given as existing publisher name' do
    existing_publisher_name = @publisher.name
    assert_difference -> { Book.count } => 1, -> { Publisher.count } => 0 do
      book = Book.create_with_associated_models(name: @book_name, author_name: @author_name,
                                                publisher_name: existing_publisher_name, publishing_year: nil,
                                                category_names: nil)
      assert_equal book.publisher.name, existing_publisher_name
      assert book.valid?
    end
  end

  test 'new category is not created when category is given as existing category name' do
    existing_category1_name = @category1.name
    existing_category2_name = @category2.name
    assert_difference -> { Book.count } => 1, -> { Category.count } => 0 do
      book = Book.create_with_associated_models(name: @book_name, author_name: @author_name,
                                                publisher_name: @publisher_name, publishing_year: nil,
                                                category_names: "#{existing_category1_name}, #{existing_category2_name}")
      assert_equal book.categories.map(&:name).sort, [existing_category1_name, existing_category2_name].sort
      assert book.valid?
    end
  end

  test 'should rollback associated models creation when book create validation fails' do
    assert_no_difference ['Book.count', 'Author.count', 'Publisher.count', 'Category.count'] do
      book = Book.create_with_associated_models(name: nil, author_name: @author_name,
                                                publisher_name: @publisher_name, publishing_year: @publishing_year,
                                                category_names: @categories)
      # name is blank and hence book create is invalid
      assert book.invalid?
    end
  end

  test 'newly created (unborrowed book) should be available' do
    unborrowed_book = Book.create(
      name: 'New Book',
      publishing_year: 2019,
      author: @author,
      categories: [@category1, @category2],
      publisher: @publisher
    )
    assert unborrowed_book.valid?

    assert unborrowed_book.available?
  end

  test 'book should be available if it is returned and no active book rental is present' do
    returned_book = book_rentals(:returned).book
    assert returned_book.valid?
    assert returned_book.available?
  end

  test 'book should be unavailable if there is an active book rental' do
    unreturned_book = book_rentals(:unreturned).book
    assert unreturned_book.valid?
    assert_not unreturned_book.available?
  end

  test 'returned and then borrowed again book should be unavailable' do
    returned_and_borrowed_again_book = book_rentals(:returned_and_borrowed_again).book
    assert returned_and_borrowed_again_book.valid?
    assert_not returned_and_borrowed_again_book.available?
  end

  test 'newly created book should be in the list of available books' do
    book = Book.create(
      name: 'New Book',
      publishing_year: 2019,
      author: @author,
      categories: [@category1, @category2],
      publisher: @publisher
    )
    assert book.valid?

    assert_includes Book.available, book
  end

  test 'returned book should be in the list of available books' do
    returned_book = book_rentals(:returned).book
    assert returned_book.valid?

    assert_includes Book.available, returned_book
  end

  test 'unreturned book should not be in the list of available books' do
    unreturned_book = book_rentals(:unreturned).book
    assert unreturned_book.valid?

    assert_not_includes Book.available, unreturned_book
  end

  test 'returned then borrowed again book should not be in the list of available books' do
    returned_and_borrowed_again_book = book_rentals(:returned_and_borrowed_again).book
    assert returned_and_borrowed_again_book.valid?

    assert_not_includes Book.available, returned_and_borrowed_again_book
  end

  test 'search should match book by name' do
    book = books(:five_point_someone)
    assert_includes Book.search(book.name), book
  end

  test 'search should match book by partial name' do
    book = books(:five_point_someone)
    assert_includes Book.search(book.name[..-2]), book
  end

  test 'search should match book by author name' do
    book = books(:five_point_someone)
    assert_includes Book.search(book.author.name), book
  end

  test 'search should match book by partial author name' do
    book = books(:five_point_someone)
    assert_includes Book.search(book.author.name[..-2]), book
  end

  test 'search should not match any book for a gibberish search term' do
    search_results = Book.search('bodkinromero')
    assert_empty search_results
  end

  test 'empty search query should return all books' do
    search_results = Book.search('')
    assert_equal Book.all, search_results
  end

  test 'search should return only the max number of results given' do
    book = books(:five_point_someone)
    dup_book = book.dup
    dup_book.custom_number = 'B00099' # Ensure uniqueness
    assert dup_book.valid?
    dup_book.save!

    limited_search_results = Book.search(book.name, 1)
    assert_equal 1, limited_search_results.count

    normal_search_results = Book.search(book.name)
    assert_equal 2, normal_search_results.count
  end

  test 'unavailable books should not contain returned book' do
    book = book_rentals(:returned).book
    assert_not_includes Book.unavailable, book
  end

  test 'unavailable books should not contain unborrowed book' do
    book = books(:unborrowed)
    assert_not_includes Book.unavailable, book
  end

  test 'unavailable books should contain unreturned book' do
    book = book_rentals(:unreturned).book
    assert_includes Book.unavailable, book
  end

  test 'unavailable books should contain returned then borrowed again book' do
    book = book_rentals(:returned_and_borrowed_again).book
    assert_includes Book.unavailable, book
  end

  test 'filter_by_availability should return available books when called with string "true"' do
    filter_results = Book.filter_by_availability('true')
    assert_equal Book.available, filter_results
  end

  test 'filter_by_availability should return available books when called with boolean true' do
    filter_results = Book.filter_by_availability(true)
    assert_equal Book.available, filter_results
  end

  test 'filter_by_availability should return unavailable books when called with string "false"' do
    filter_results = Book.filter_by_availability('false')
    assert_equal Book.unavailable, filter_results
  end

  test 'filter_by_availability should return unavailable books when called with boolean false' do
    filter_results = Book.filter_by_availability(false)
    assert_equal Book.unavailable, filter_results
  end

  test 'filter_by_available should return all books when called with any other value' do
    filter_results = Book.filter_by_availability(nil)
    assert_equal Book.all, filter_results

    filter_results = Book.filter_by_availability('t')
    assert_equal Book.all, filter_results

    filter_results = Book.filter_by_availability('f')
    assert_equal Book.all, filter_results

    filter_results = Book.filter_by_availability('random')
    assert_equal Book.all, filter_results
  end
end
