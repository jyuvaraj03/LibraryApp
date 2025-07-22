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
               book_id: available_book.id,
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
               book_id: unavailable_book.id,
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
               book_id: available_book.id,
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
               book_id: available_book.id,
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
end
