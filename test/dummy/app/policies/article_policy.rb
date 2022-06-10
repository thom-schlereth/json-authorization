class ArticlePolicy < ApplicationPolicy
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
    true
    # raise NotImplementedError
  end

  def destroy?
    raise NotImplementedError
  end

  def create_with_author?(_author)
    raise NotImplementedError
  end

  def create_with_comments?(_comments)
    raise NotImplementedError
  end

  def add_to_comments?(_comments)
    raise NotImplementedError
  end

  def replace_comments?(_comments)
    raise NotImplementedError
  end

  def remove_from_comments?(_comment)
    raise NotImplementedError
  end

  def replace_author?(_author)
    raise NotImplementedError
  end

  def remove_author?
    raise NotImplementedError
  end
end
