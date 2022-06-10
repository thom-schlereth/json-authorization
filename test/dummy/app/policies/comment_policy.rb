class CommentPolicy < ApplicationPolicy

  def index?
    raise NotImplementedError
  end

  def show?
    raise NotImplementedError
  end

  def create?
    true
  end

  def update?
    raise NotImplementedError
  end

  def destroy?
    raise NotImplementedError
  end
end
