require 'test_helper'

class MembersHelperTest < ActionView::TestCase
  test 'member_form_field renders label and input' do
    member = Member.new
    form_builder = ActionView::Helpers::FormBuilder.new(:member, member, self, {})
    html = member_form_field(form_builder, :name, :text_field, required: true, placeholder: 'Name')
    assert_includes html, 'required-field-label'
    assert_includes html, 'placeholder="Name"'
    assert_includes html, 'type="text"'
    assert_includes html, 'name="member[name]"'
  end
end
