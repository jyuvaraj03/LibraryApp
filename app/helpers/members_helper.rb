module MembersHelper
  # DRY form field helper for member form
  def member_form_field(form, field, type, label_text: nil, required: false, placeholder: nil, min: nil, max: nil)
    label_classes = "block mb-2 font-medium"
    label_classes += " required-field-label" if required
    input_classes = "shadow border px-4 py-2 w-full rounded"
    label_text ||= t("#{field}_label")
    input_options = { class: input_classes }
    input_options[:required] = true if required
    input_options[:placeholder] = placeholder if placeholder
    input_options[:min] = min if min
    input_options[:max] = max if max
    content_tag :div, class: "flex flex-col mb-6" do
      form.label(field, label_text, class: label_classes) +
      form.send(type, field, input_options)
    end
  end
end
