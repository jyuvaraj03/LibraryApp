require "test_helper"

class MembersControllerTest < ActionDispatch::IntegrationTest
  test 'should not be able to get index when not logged in' do
    get members_path
    assert_redirected_to root_path
    assert_equal I18n.t('not_authorized'), flash[:danger]
  end

  test 'should not be able to get new page when not logged in' do
    get new_member_path
    assert_redirected_to root_path
    assert_equal I18n.t('not_authorized'), flash[:danger]
  end

  test 'should not be able to create new member when not logged in' do
    post members_path
    assert_redirected_to root_path
    assert_equal I18n.t('not_authorized'), flash[:danger]
  end

  test 'should be able to get index when logged in' do
    log_in_as staffs(:admino)
    assert_nothing_raised do
      get members_path
      assert_response :success
    end
  end

  test 'should be able to get new page when logged in' do
    log_in_as staffs(:admino)
    assert_nothing_raised do
      get new_member_path
      assert_response :success
    end
  end

  test 'should be able to create new member when logged in' do
    log_in_as staffs(:admino)
    assert_nothing_raised do
      # Manual custom_number
      post members_path, params: { member: { name: 'New Member', personal_number: 1234, custom_number: 'M999999' } }
      assert_response :redirect
      member = Member.find_by(personal_number: 1234)
      assert_equal 'M999999', member.custom_number

      # Auto-assign custom_number
      post members_path, params: { member: { name: 'Auto Member', personal_number: 1235, auto_assign_custom_number: true } }
      assert_response :redirect
      auto_member = Member.find_by(personal_number: 1235)
      assert auto_member.custom_number.present?
      assert_match /^M\S+$/, auto_member.custom_number
    end
  end

  test 'should throw flash when creating a second member with same mobile number' do
    log_in_as staffs(:admino)
    assert_difference 'Member.count' do
      post members_path, params: { member: { name: 'New Member', personal_number: 1234, phone: '9876543210' } }
      assert_response :redirect
    end
    post members_path, params: { member: { name: 'New member 2', personal_number: 2345, phone: '9876543210' } }
    assert_not_nil flash[:form_errors]
    assert_response :success
  end
end
