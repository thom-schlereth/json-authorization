class UserPolicy < ApplicationPolicy

  def create?
    true
  end

  def update?
    true
  end

  def destroy?
    true
  end
end
