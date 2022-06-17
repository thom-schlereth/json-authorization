class User < ApplicationRecord
  has_many :articles, foreign_key: :author_id
  has_many :comments, foreign_key: :author_id

  scope :scope_model, ->(policy) {
    self.where('author_id = ?', policy.dig(:show, :message))
  }

  scope :scoped_article, ->(policy) {
    # comment = Comment.find(policy.values.dig(0,:message))
    # Article.where(comments: comment)
    # binding.pry
    # User.where(id: comment.author.id)
    self.all
  }

  # scope :by_author_id_for_comment, ->(policy) {
  #   self.where('id = ?', policy.dig(:scope, :message))
  # }

end
