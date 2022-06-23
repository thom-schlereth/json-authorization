class ApplicationPolicy
  attr_reader :user, :policy, :record

  def initialize(context, record)
    @user = context[:user] if context
    @policy = context[:policy] if context
    @record = record
  end

  def index?
    return true unless policy
    if policy.dig(:forbidden, :action) == :index && policy.dig(:forbidden, :klass) == record.to_s
      false
    else
      true
    end
  end

  def show?
    return true unless policy
    if policy.dig(:forbidden, :action) == :show && policy.dig(:forbidden, :klass) == record.class.to_s
      false
    else
      true
    end
  end

  def update?
    return true unless policy
    if policy.dig(:forbidden, :action) == :update && policy.dig(:forbidden, :klass) == record.class.to_s
      false
    else
      true
    end
  end

  def create?
    return true unless policy
    if policy.dig(:forbidden, :action) == :create && policy.dig(:forbidden, :klass) == record.to_s
      false
    else
      true
    end
  end

  class Scope < Struct.new(:context, :scope)

    attr_reader :policy, :user, :scope

    def initialize(context, scope)
      @user = context[:user] if context
      @policy = context[:policy] if context
      @scope = scope
    end

    def resolve
      return model.all unless policy
      return model.all if policy.dig(:forbidden)
      case policy.dig(:scope,:title)
      when :by_article_external_id
        scope.by_article_external_id(policy)
      when :by_article_not_found
        scope.by_article_not_found(policy)
      when :by_comments_not_found
        scope.by_comments_not_found(policy)
      when :by_comment_id
        scope.by_comment_id(policy)
      when :by_article_first_comment_id
        scope.by_article_first_comment_id(policy)
      when :by_articles_first_comment_id
        scope.by_articles_first_comment_id(policy)
      else
        model.all
      end
    end

    private

    def model
      scope.name.safe_constantize
    end
  end

end
