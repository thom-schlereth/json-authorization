class ArticlePolicy < ApplicationPolicy

  def create_with_author?(_author)
    true
  end

  def create_with_comments?(_comments)
    return true unless policy
    if policy.dig(:forbidden, :action) == :create && policy.dig(:forbidden, :klass) == record.to_s
      false
    else
      true
    end
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
    return true unless policy
    if policy.dig(:forbidden, :action) == :create && policy.dig(:forbidden, :klass) == record.class.to_s
      false
    else
      true
    end
  end

  def remove_from_comments?(_comment)
    return true unless policy
    if policy.dig(:forbidden, :action) == :destroy && policy.dig(:forbidden, :klass) == "Comment"
      false
    else
      true
    end
  end

  def replace_author?(_author)
    return true unless policy
    if policy.dig(:forbidden, :action) == :create && policy.dig(:forbidden, :klass) == record.class.to_s
      false
    else
      true
    end
  end

  def remove_author?
    return true unless policy
    if policy.dig(:forbidden, :action) == :destroy && policy.dig(:forbidden, :klass) == "Author"
      false
    else
      true
    end
  end
end
