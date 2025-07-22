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
end
