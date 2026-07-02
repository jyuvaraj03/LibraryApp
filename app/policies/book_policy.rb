class BookPolicy < ApplicationPolicy
  def new?
    user&.admin?
  end

  def create?
    user&.admin?
  end

  def update?
    user&.admin?
  end

  def index?
    true
  end
end
