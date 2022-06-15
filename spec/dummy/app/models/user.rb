class User < ActiveRecord::Base
  has_many :articles, foreign_key: :author_id
  has_many :comments, foreign_key: :author_id

  scope :index_scope, ->(policy) {
    self.all
  }

  scope :show_scope, ->(policy) {
    self.where('author_id = ?', policy.dig(:show, :message))
  }

end
