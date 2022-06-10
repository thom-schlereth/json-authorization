class ApplicationPolicy
  attr_reader :user, :status_type, :record

  def initialize(context, record)
    @user = context[:user]
    @status_type = context[:status_type]
    @record = record
  end

  class Scope < Struct.new(:context, :scope)

    attr_reader :status_type, :user, :scope

    def initialize(context, scope)
      @user = context[:user]
      @status_type = context[:status_type]
      @scope = scope
    end

    def resolve
      case status_type
      when 201
        model.all
      when 403
        raise Pundit::NotAuthorizedError
      when 404
        model.none
      end
    end

    private

    def model
      scope.name.safe_constantize
    end
  end

end
