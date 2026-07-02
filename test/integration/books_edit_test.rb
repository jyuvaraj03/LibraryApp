require 'test_helper'

class BooksEditTest < ActionDispatch::IntegrationTest
  def setup
    super
    @book = books(:five_point_someone)
    @original_custom_number = @book.custom_number
    log_in_as(staffs(:admino))
  end

  test 'admin can click a book title from the listing page to edit it' do
    get books_path
    assert_response :success
    assert_select 'a[href=?]', edit_book_path(@book), text: @book.name
  end

  test 'edit form includes editable details but not the book id' do
    get edit_book_path(@book)
    assert_response :success
    assert_select 'input[name=?]', 'book[custom_number]', count: 0
    assert_select 'input[name=?]', 'book[name]'
    assert_select 'input[name=?]', 'book[author_name]'
    assert_select 'input[name=?]', 'book[publisher_name]'
    assert_select 'input[name=?]', 'book[publishing_year]'
    assert_select 'input[name=?]', 'book[category_names]'
    assert_select 'input[name=?]', 'book[price]'
  end

  test 'admin can update all editable book details without changing the book id' do
    patch book_path(@book), params: {
      id: 999_999,
      book: {
        custom_number: 'B99999',
        name: 'Updated Book Name',
        author_name: 'Updated Author',
        publisher_name: 'Updated Publisher',
        publishing_year: '2020',
        category_names: 'Updated Category, Another Category',
        price: '123.45'
      }
    }

    assert_redirected_to books_path
    assert_equal I18n.t('successfully_updated_book_name', name: 'Updated Book Name'), flash[:snack_success]

    @book.reload
    assert_equal @original_custom_number, @book.custom_number
    assert_equal 'Updated Book Name', @book.name
    assert_equal 'Updated Author', @book.author.name
    assert_equal 'Updated Publisher', @book.publisher.name
    assert_equal 2020, @book.publishing_year
    assert_equal ['Another Category', 'Updated Category'], @book.categories.map(&:name).sort
    assert_equal BigDecimal('123.45'), @book.price
  end

  test 'invalid update renders edit and does not persist partial changes' do
    original_author = @book.author
    original_category_names = @book.categories.map(&:name).sort

    patch book_path(@book), params: {
      book: {
        name: '',
        author_name: 'Invalid Update Author',
        publisher_name: 'Invalid Update Publisher',
        publishing_year: '2020',
        category_names: 'Invalid Update Category',
        price: '99'
      }
    }

    assert_response :success
    assert_select 'p', text: I18n.t('edit_book')

    @book.reload
    assert_equal 'Five Point Someone', @book.name
    assert_equal original_author, @book.author
    assert_equal original_category_names, @book.categories.map(&:name).sort
    assert_nil Author.find_by(name: 'Invalid Update Author')
    assert_nil Publisher.find_by(name: 'Invalid Update Publisher')
    assert_nil Category.find_by(name: 'Invalid Update Category')
  end
end
