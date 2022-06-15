class ApplicationPolicy
  attr_reader :user, :policy, :record

  def initialize(context, record)
    @user = context[:user]
    @policy = context[:policy]
    @record = record
  end

  def index?
    if policy.dig(:index, :forbidden) && policy.dig(:index, :klass) == record.to_s
      false
    else
      true
    end
  end

  def show?
    if policy.dig(:show, :forbidden) && policy.dig(:show, :klass) == record.class.to_s
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
      # binding.pry
      case policy.keys.first
      when :index
        scope.index_scope(policy)
      when :show
        scope.show_scope(policy)
      end
      # if policy[:show]
        # scope.show_scope(policy)
      # end
    end

    private

    def model
      scope.name.safe_constantize
    end
  end

end
