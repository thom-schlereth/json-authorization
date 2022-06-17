class ApplicationPolicy
  attr_reader :user, :policy, :record

  def initialize(context, record)
    @user = context[:user]
    @policy = context[:policy]
    @record = record
  end

  def index?
    if policy.dig(:forbidden, :action) == :index && policy.dig(:forbidden, :klass) == record.to_s
      false
    else
      true
    end
  end

  def show?
    if policy.dig(:forbidden, :action) == :show && policy.dig(:forbidden, :klass) == record.class.to_s
      false
    else
      true
    end
  end

  def update?
    if policy.dig(:forbidden, :action) == :update && policy.dig(:forbidden, :klass) == record.class.to_s
      false
    else
      true
    end
  end

  def create?
    if policy.dig(:forbidden, :action) == :create && policy.dig(:forbidden, :klass) == record.to_s
      false
    else
      true
    end
  end

  class Scope < Struct.new(:context, :scope)

    attr_reader :policy, :user, :scope

    def initialize(context, scope)
      @user = context[:user]
      @policy = context[:policy]
      @scope = scope
    end

    def resolve
      return model.all if policy.dig(:forbidden)
      case policy.dig(:scope,:title)
      when :by_article_id
        scope.by_article_id(policy)
      when :by_article_id
        scope.by_author_id_for_comment(policy)
      when :show
        scope.show_scope(policy)
      when :by_article_first_comment_id
        scope.by_article_first_comment_id(policy)
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
