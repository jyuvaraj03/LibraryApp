require "test_helper"

class BooksControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get books_path
    assert_response :success
  end

  test 'should not be able to access new book page when not logged in' do
    get new_book_path
    assert_redirected_to root_path
    assert_equal I18n.t('not_authorized'), flash[:danger]
  end

  test 'should not be able to create new book when not logged in' do
    post books_path
    assert_redirected_to root_path
    assert_equal I18n.t('not_authorized'), flash[:danger]
  end

  test 'should be able to access index page when not logged in' do
    get books_path
    assert_response :success
  end

  test 'should not be able to access edit book page when not logged in' do
    get edit_book_path(books(:five_point_someone))
    assert_redirected_to root_path
    assert_equal I18n.t('not_authorized'), flash[:danger]
  end

  test 'should not be able to update book when not logged in' do
    patch book_path(books(:five_point_someone)), params: { book: { name: 'Updated Name' } }
    assert_redirected_to root_path
    assert_equal I18n.t('not_authorized'), flash[:danger]
  end

  test 'librarian should not be able to access edit book page' do
    log_in_as(staffs(:libster))
    get edit_book_path(books(:five_point_someone))
    assert_redirected_to root_path
    assert_equal I18n.t('not_authorized'), flash[:danger]
  end

  test 'librarian should not be able to update book' do
    book = books(:five_point_someone)
    log_in_as(staffs(:libster))
    patch book_path(book), params: { book: { name: 'Updated Name' } }
    assert_redirected_to root_path
    assert_equal I18n.t('not_authorized'), flash[:danger]
    assert_equal 'Five Point Someone', book.reload.name
  end
end
