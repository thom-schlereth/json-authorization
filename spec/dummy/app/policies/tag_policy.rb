class TagPolicy < ApplicationPolicy

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
