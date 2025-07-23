module CustomNumberAssignable
  extend ActiveSupport::Concern

  included do
    before_validation :ensure_custom_number
  end

  module ClassMethods
    def generate_unique_custom_number(prefix = 'C', length = 6, column = :custom_number)
      loop do
        number = "#{prefix}#{SecureRandom.hex(length)}"
        break number unless self.exists?(column => number)
      end
    end
  end

  private

  def ensure_custom_number
    col = self.class.try(:custom_number_column) || :custom_number
    prefix = self.class.try(:custom_number_prefix) || 'C'
    length = self.class.try(:custom_number_length) || 6
    self[col] = self[col].presence || self.class.generate_unique_custom_number(prefix, length, col)
  end
end
