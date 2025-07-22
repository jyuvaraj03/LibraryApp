require 'test_helper'

class ReturnsControllerTest < ActionDispatch::IntegrationTest
  def setup
    log_in_as staffs(:admino)
  end

  test 'should get new' do
    get new_return_path
    assert_response :success
  end

  test 'should create new return' do
    book_rental = book_rentals(:unreturned)
    assert book_rental.returned_on.nil?
    returning_on = Date.today
    post returns_path,
         params: {
           return: {
             member_id: book_rental.member.id,
             returned_on: returning_on.to_s,
             book_rental_ids: [book_rental.id]
           }
         }
    assert book_rental.returned_on = returning_on
  end

  test 'should not be able to get new page when logged out' do
    delete logout_path
    get new_return_path
    assert_redirected_to root_path
    assert_equal I18n.t('not_authorized'), flash[:danger]
  end

  test 'should not be able to create new return when logged out' do
    delete logout_path
    post returns_path
    assert_redirected_to root_path
    assert_equal I18n.t('not_authorized'), flash[:danger]
  end
end
