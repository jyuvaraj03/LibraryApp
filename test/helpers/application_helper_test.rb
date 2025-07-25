require 'test_helper'

class ApplicationHelperTest < ActionView::TestCase
  test 'form_field renders label and input for generic model' do
    book = Book.new
    form_builder = ActionView::Helpers::FormBuilder.new(:book, book, self, {})
    html = form_field(form_builder, :name, :text_field, required: true, placeholder: 'Book Name')
    assert_includes html, 'required-field-label'
    assert_includes html, 'placeholder="Book Name"'
    assert_includes html, 'type="text"'
    assert_includes html, 'name="book[name]"'
    assert_includes html, 'block mb-2 font-medium'
    assert_includes html, 'shadow border px-4 py-2 w-full rounded'
  end

  test 'form_field works for member model as well' do
    member = Member.new
    form_builder = ActionView::Helpers::FormBuilder.new(:member, member, self, {})
    html = form_field(form_builder, :name, :text_field, required: true, placeholder: 'Member Name')
    assert_includes html, 'required-field-label'
    assert_includes html, 'placeholder="Member Name"'
    assert_includes html, 'type="text"'
    assert_includes html, 'name="member[name]"'
  end

  test 'form_field supports email_field type' do
    member = Member.new
    form_builder = ActionView::Helpers::FormBuilder.new(:member, member, self, {})
    html = form_field(form_builder, :email, :email_field, placeholder: 'Email')
    assert_includes html, 'type="email"'
    assert_includes html, 'name="member[email]"'
    assert_includes html, 'placeholder="Email"'
  end

  test 'form_field supports date_field type with min and max' do
    member = Member.new
    form_builder = ActionView::Helpers::FormBuilder.new(:member, member, self, {})
    html = form_field(form_builder, :date_of_birth, :date_field, min: '1900-01-01', max: '2025-12-31')
    assert_includes html, 'type="date"'
    assert_includes html, 'min="1900-01-01"'
    assert_includes html, 'max="2025-12-31"'
  end

  test 'form_field applies custom field_class and div_class' do
    member = Member.new
    form_builder = ActionView::Helpers::FormBuilder.new(:member, member, self, {})
    html = form_field(form_builder, :email, :text_field, field_class: 'custom-class', div_class: 'custom-div')
    assert_includes html, 'custom-class'
    assert_includes html, 'class="custom-div"'
  end

  test 'form_field uses custom label_text' do
    member = Member.new
    form_builder = ActionView::Helpers::FormBuilder.new(:member, member, self, {})
    html = form_field(form_builder, :name, :text_field, label_text: 'Custom Label')
    assert_includes html, 'Custom Label'
  end

  test 'form_field merges additional options' do
    member = Member.new
    form_builder = ActionView::Helpers::FormBuilder.new(:member, member, self, {})
    html = form_field(form_builder, :name, :text_field, autofocus: true, data: { foo: 'bar' })
    assert_includes html, 'autofocus="autofocus"'
    assert_includes html, 'data-foo="bar"'
  end
end
