class User < ApplicationRecord
  has_many :articles, foreign_key: :author_id
  has_many :comments, foreign_key: :author_id

  scope :scope_model, ->(policy) {
    self.where('author_id = ?', policy.dig(:show, :message))
  }

  scope :scoped_article, ->(policy) {
    self.all
  }

end
