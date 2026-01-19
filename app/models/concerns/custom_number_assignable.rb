module CustomNumberAssignable
  extend ActiveSupport::Concern

  included do
    validates :custom_number, presence: true, uniqueness: true
  end
end
