# frozen_string_literal: true

require 'test_helper'

class BookRentalsControllerTest < ActionDispatch::IntegrationTest
  def setup
    log_in_as staffs(:admino)
  end

  test 'should get index' do
    get book_rentals_path
    assert_response :success
  end

  test 'should create book rental if book is available' do
    available_book = books(:unborrowed)
    member = members(:phineas)

    assert member.book_rentals.current.count < BookRental::MAX_RENTALS, "Test setup error: member already has max rentals"

    get new_book_rental_path
    assert_response :success

    assert_difference 'BookRental.count' do
      post book_rentals_path,
           params: {
             book_rental: {
               book_id: [available_book.id],
               member_id: member.id,
               issued_on: Date.today.to_formatted_s
             }
           }
      assert flash[:form_errors].blank?
      assert_response :redirect
      follow_redirect!
      assert_template 'book_rentals/index'
    end
  end

  test 'should not create book rental if book is unavailable' do
    unavailable_book = book_rentals(:unreturned).book
    member = members(:johnny)

    get new_book_rental_path
    assert_response :success

    assert_no_difference 'BookRental.count' do
      post book_rentals_path,
           params: {
             book_rental: {
               book_id: [unavailable_book.id],
               member_id: member.id,
               issued_on: Date.today.to_formatted_s
             }
           }
      assert_template 'book_rentals/new'
      assert_not flash.empty?
      get root_path
      assert flash.empty?
    end
  end

  test 'should not be able to borrow more than max number of books' do
    available_book = book_rentals(:returned).book
    member = members(:johnny)
    assert member.book_rentals.current.count >= BookRental::MAX_RENTALS

    get new_book_rental_path
    assert_response :success

    assert_no_difference 'BookRental.count' do
      post book_rentals_path,
           params: {
             book_rental: {
               book_id: [available_book.id],
               member_id: member.id,
               issued_on: Date.today.to_formatted_s
             }
           }
      assert_template 'book_rentals/new'
      assert_not flash.empty?
      get root_path
      assert flash.empty?
    end
  end

  test 'should create book rental for member with no current rentals' do
    available_book = books(:unborrowed)
    member = members(:phineas)

    get new_book_rental_path
    assert_response :success

    assert_difference 'BookRental.count' do
      post book_rentals_path,
           params: {
             book_rental: {
               book_id: [available_book.id],
               member_id: member.id,
               issued_on: Date.today.to_formatted_s
             }
           }
      assert flash[:form_errors].blank?
      assert_response :redirect
      follow_redirect!
      assert_template 'book_rentals/index'
    end
  end

  test 'should not be able to get index when logged out' do
    delete logout_path
    get book_rentals_path
    assert_redirected_to root_path
    assert_equal I18n.t('not_authorized'), flash[:danger]
  end

  test 'should not be able to get new page when logged out' do
    delete logout_path
    get new_book_rental_path
    assert_redirected_to root_path
    assert_equal I18n.t('not_authorized'), flash[:danger]
  end

  test 'should not be able to create new book rental when logged out' do
    delete logout_path
    post book_rentals_path
    assert_redirected_to root_path
    assert_equal I18n.t('not_authorized'), flash[:danger]
  end

  test 'should create multiple book rentals for a member in one request' do
    member = members(:phineas)
    books = [books(:five_point_someone), books(:unborrowed)]
    assert member.book_rentals.current.count == 0

    assert_difference 'BookRental.count', 2 do
      post book_rentals_path, params: {
        book_rental: {
          book_id: books.map(&:id),
          member_id: member.id,
          issued_on: Date.today.to_formatted_s
        }
      }
      assert flash[:form_errors].blank?, flash[:form_errors].inspect
      assert_response :redirect
      follow_redirect!
      assert_template 'book_rentals/index'
    end
    assert_equal books.map(&:id).sort, member.book_rentals.current.pluck(:book_id).sort
  end

  test 'should not create rentals if request exceeds max rentals' do
    member = members(:johnny)
    # Johnny already has 2 current rentals (MAX_RENTALS)
    books = [books(:five_point_someone), books(:oliver_twist)]
    assert member.book_rentals.current.count == BookRental::MAX_RENTALS

    assert_no_difference 'BookRental.count' do
      post book_rentals_path, params: {
        book_rental: {
          book_id: books.map(&:id),
          member_id: member.id,
          issued_on: Date.today.to_formatted_s
        }
      }
      assert_template 'book_rentals/new'
      assert_includes flash[:form_errors].first, I18n.t('exceeds_max_rentals', max: BookRental::MAX_RENTALS)
    end
  end

  test 'should not create any rentals if one book is unavailable (transaction rollback)' do
    member = members(:phineas)
    available = books(:five_point_someone)
    unavailable = book_rentals(:unreturned).book
    assert member.book_rentals.current.count == 0

    assert_no_difference 'BookRental.count' do
      post book_rentals_path, params: {
        book_rental: {
          book_id: [available.id, unavailable.id],
          member_id: member.id,
          issued_on: Date.today.to_formatted_s
        }
      }
      assert_template 'book_rentals/new'
      assert flash[:form_errors].present?
      assert member.book_rentals.current.empty?
    end
  end
end
