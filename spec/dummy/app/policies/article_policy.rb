class ArticlePolicy < ApplicationPolicy

  def destroy?
    true
  end

  def create_with_author?(_author)
    true
  end

  def create_with_comments?(_comments)
    true
  end

  def add_to_comments?(_comments)
    return true unless policy
    if policy.dig(:forbidden, :action) == :create && policy.dig(:forbidden, :klass) == record.class.to_s
      false
    else
      true
    end
  end

  def replace_comments?(_comments)
    true
  end

  def remove_from_comments?(_comment)
    true
  end

  def replace_author?(_author)
    true
  end

  def remove_author?
    true
  end
end
