class CommentPolicy < ApplicationPolicy

  def create_with_article?(_article)
    return true unless policy
    if policy.dig(:forbidden, :action) == :create && policy.dig(:forbidden, :klass) == record.to_s
      false
    else
      true
    end
  end
end
