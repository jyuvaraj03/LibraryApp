# frozen_string_literal: true

require 'test_helper'

class MemberTest < ActiveSupport::TestCase
  def setup
    @member = members(:johnny)
  end

  test 'should be valid' do
    @member.valid?
  end

  test 'member should have name' do
    @member.name = nil
    assert @member.invalid?
  end

  test 'member should have personal number' do
    @member.personal_number = nil
    assert @member.invalid?
  end

  test 'personal number should be a positive integer' do
    @member.personal_number = 'abcd'
    assert @member.invalid?

    @member.personal_number = '-1234'
    assert @member.invalid?
  end

  test 'personal number should be unique' do
    another_member = members(:phineas)
    assert another_member.valid?
    another_member.personal_number = @member.personal_number
    assert another_member.invalid?
    assert another_member.errors.include? :personal_number
  end

  test 'email can be blank' do
    @member.email = nil
    @member.save
    assert @member.valid?
  end

  test 'multiple nil emails can be present' do
    @member.email = nil
    @member.save

    another_member = members(:phineas)
    another_member.email = nil
    another_member.save

    assert @member.valid?
    assert another_member.valid?
  end

  test 'phone number can be blank' do
    @member.phone = nil
    assert @member.valid?

    @member.phone = ''
    assert @member.valid?
  end

  test 'phone number should be 10 digits' do
    @member.phone = '123456789'
    assert @member.invalid?

    @member.phone = '12345678901'
    assert @member.invalid?

    @member.phone = '1234567890'
    assert @member.valid?
  end

  test 'multiple nil phones can be present' do
    @member.phone = nil
    @member.save!

    another_member = members(:phineas)
    another_member.phone = nil
    another_member.save!

    assert @member.valid?
    assert another_member.valid?
  end

  test 'search by name should match member by name' do
    member = members(:johnny)
    assert_includes Member.search(member.name), member
  end

  test 'search by id should match member by custom number' do
    member = members(:johnny)
    assert_includes Member.search(member.custom_number), member
  end

  test 'search by id should match member by personal number' do
    member = members(:johnny)
    assert_includes Member.search(member.personal_number), member
  end

  test 'empty search query should return all members' do
    search_results = Member.search('')
    assert_equal Member.all, search_results
  end

  test 'members who can rent should be computed' do
    member = members(:phineas)
    assert member.book_rentals.current.count <= BookRental::MAX_RENTALS
    assert_includes Member.can_rent, member
  end

  test 'members who can rent should includes members with rentals that have been returned' do
    member = members(:phineas)
    BookRental.create(member:, returned_on: Time.now, issued_on: Time.now - 1.day, book: books(:five_point_someone))
    BookRental.create(member:, returned_on: Time.now, issued_on: Time.now - 1.day,
                      book: books(:unborrowed))
    assert member.book_rentals.current.count <= BookRental::MAX_RENTALS
    assert_includes Member.can_rent, member
  end

  test 'members who can rent should not includes members with more than or equal to max rentals' do
    member = members(:johnny)
    assert member.book_rentals.current.count >= BookRental::MAX_RENTALS
    assert_not_includes Member.can_rent, member
  end

  test 'members filter_by_can_rent calls the correct scope' do
    Member.expects(:can_rent).once
    Member.filter_by_can_rent('true')
    Member.expects(:all).once
    Member.filter_by_can_rent('false')
  end
end
