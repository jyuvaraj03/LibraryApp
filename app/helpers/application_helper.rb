# frozen_string_literal: true

module ApplicationHelper
  include Pagy::Frontend

  def form_field(form, field, type, label_text: nil, required: false, placeholder: nil, min: nil, max: nil, field_class: nil, div_class: 'flex flex-col mb-6', **options)
    label_classes = 'block mb-2 font-medium'
    label_classes += ' required-field-label' if required
    input_classes = 'shadow border px-4 py-2 w-full rounded'
    input_classes += " #{field_class}" if field_class.present?
    label_text ||= t("#{field}_label")
    input_options = { required: required, placeholder: placeholder, min: min, max: max, class: input_classes }.merge(options)
    content_tag :div, class: div_class do
      form.label(field, label_text, class: label_classes) +
      form.send(type, field, input_options)
    end
  end
end
