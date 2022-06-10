class ArticlePolicy
  class Scope < Struct.new(:user, :scope)
    def resolve
      Article.all
    end
  end

  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  def index?
    true
  end

  def show?
    true
  end

  def create?
    true
  end

  def update?
    true
  end

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
    true
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
