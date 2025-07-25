module CustomNumberAssignable
  extend ActiveSupport::Concern

  included do
    before_validation :ensure_custom_number
  end

  private

  # Ensures the custom number is set before validation.
  # Example: 'C000012' for prefix 'C', length 6
  def ensure_custom_number
    col = self.class.try(:custom_number_column) || :custom_number

    return if self[col].present?

    prefix = self.class.try(:custom_number_prefix) || 'C'
    length = self.class.try(:custom_number_length) || 6
    self.class.transaction do
      last_pattern = self.class.order(col).lock(true).last&.send(col)
      last_number = last_pattern ? last_pattern.gsub("#{prefix}", '').to_i : 0
      new_pattern = "#{prefix}#{(last_number + 1).to_s.rjust(length, '0')}"
      self[col] = new_pattern
    end
  end
end
