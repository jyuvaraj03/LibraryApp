class MemberPolicy < ApplicationPolicy
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
    !!user
  end
end
