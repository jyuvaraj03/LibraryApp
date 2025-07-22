# frozen_string_literal: true

require 'test_helper'

class CreateMemberTest < ActionDispatch::IntegrationTest
  def setup
    log_in_as staffs(:admino)
  end
  test 'should create member with only the required fields' do
    get new_member_path
    assert_response :success
    assert_template 'members/new'

    assert_difference 'Member.count' do
      post members_path,
           params: {
             member: {
               name: 'Barack',
               personal_number: 6789
             }
           }
      assert_response :redirect
      follow_redirect!
      assert_response :success
    end
  end

  test 'should not create member when required fields are blank' do
    get new_member_path
    assert_response :success
    assert_template 'members/new'

    assert_no_difference 'Member.count' do
      post members_path,
           params: {
             member: {
               name: 'Barack',
               personal_number: nil
             }
           }
      assert_response :success
      assert_template 'members/new'
      assert_not_nil flash[:form_errors]
    end
  end

  test 'should use nil values for fields posted with empty strings' do
    assert_difference 'Member.count' do
      post members_path,
           params: {
             member: {
               name: 'Barack',
               personal_number: 214,
               email: '',
               phone: '',
               tamil_name: '',
               date_of_birth: '',
               date_of_retirement: ''
             }
           }
      assert_response :redirect
      follow_redirect!
      assert_response :success
      created_member = Member.find_by(personal_number: 214)
      assert_nil created_member.email
      assert_nil created_member.phone
      assert_nil created_member.tamil_name
      assert_nil created_member.date_of_birth
      assert_nil created_member.date_of_retirement
    end
  end
end
