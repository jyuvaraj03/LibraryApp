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
    end
  end

  test 'should not be able to access edit member page when not logged in' do
    get edit_member_path(members(:johnny))
    assert_redirected_to root_path
    assert_equal I18n.t('not_authorized'), flash[:danger]
  end

  test 'should not be able to update member when not logged in' do
    member = members(:johnny)
    patch member_path(member), params: { member: { name: 'Updated Name' } }
    assert_redirected_to root_path
    assert_equal I18n.t('not_authorized'), flash[:danger]
    assert_equal 'Johnny', member.reload.name
  end

  test 'librarian should not be able to access edit member page' do
    log_in_as(staffs(:libster))
    get edit_member_path(members(:johnny))
    assert_redirected_to root_path
    assert_equal I18n.t('not_authorized'), flash[:danger]
  end

  test 'librarian should not be able to update member' do
    member = members(:johnny)
    log_in_as(staffs(:libster))
    patch member_path(member), params: { member: { name: 'Updated Name' } }
    assert_redirected_to root_path
    assert_equal I18n.t('not_authorized'), flash[:danger]
    assert_equal 'Johnny', member.reload.name
  end

  test 'admin should be able to access edit member page' do
    log_in_as(staffs(:admino))
    get edit_member_path(members(:johnny))
    assert_response :success
    assert_select 'input[name=?]', 'member[custom_number]', count: 0
  end

  test 'admin should be able to update editable member fields' do
    member = members(:johnny)
    log_in_as(staffs(:admino))

    patch member_path(member), params: {
      member: {
        name: 'Updated Member',
        tamil_name: 'Updated Tamil Name',
        personal_number: 4321,
        email: 'updated@example.com',
        phone: '7777777777',
        section: 'Reference',
        date_of_birth: '1990-01-02',
        date_of_retirement: '2050-03-04'
      }
    }

    assert_redirected_to members_path
    assert_equal I18n.t('successfully_updated_member_name', name: 'Updated Member'), flash[:snack_success]
    member.reload
    assert_equal 'Updated Member', member.name
    assert_equal 'Updated Tamil Name', member.tamil_name
    assert_equal 4321, member.personal_number
    assert_equal 'updated@example.com', member.email
    assert_equal '7777777777', member.phone
    assert_equal 'Reference', member.section
    assert_equal Date.new(1990, 1, 2), member.date_of_birth
    assert_equal Date.new(2050, 3, 4), member.date_of_retirement
  end

  test 'admin update ignores submitted custom number and id' do
    member = members(:johnny)
    original_id = member.id
    original_custom_number = member.custom_number
    log_in_as(staffs(:admino))

    patch member_path(member), params: {
      member: {
        id: members(:phineas).id,
        custom_number: 'M999999',
        name: 'Still Johnny',
        personal_number: member.personal_number
      }
    }

    assert_redirected_to members_path
    member.reload
    assert_equal original_id, member.id
    assert_equal original_custom_number, member.custom_number
    assert_equal 'Still Johnny', member.name
  end

  test 'admin member list links member names to edit page' do
    member = members(:johnny)
    log_in_as(staffs(:admino))

    get members_path

    assert_response :success
    assert_select "a[href='#{edit_member_path(member)}']", text: member.name
  end

  test 'librarian member list does not link member names to edit page' do
    member = members(:johnny)
    log_in_as(staffs(:libster))

    get members_path

    assert_response :success
    assert_select "a[href='#{edit_member_path(member)}']", count: 0
    assert_select 'td', text: member.name
  end

  test 'should throw flash when creating a second member with same mobile number' do
    log_in_as staffs(:admino)
    assert_difference 'Member.count' do
      post members_path, params: { member: { name: 'New Member', personal_number: 1234, phone: '9876543210', custom_number: 'M999999' } }
      assert_response :redirect
    end
    post members_path, params: { member: { name: 'New member 2', personal_number: 2345, phone: '9876543210', custom_number: 'M999999' } }
    assert_not_nil flash[:form_errors]
    assert_response :success
  end
end
