class Comment < ApplicationRecord
  has_many :tags, as: :taggable
  belongs_to :article
  belongs_to :author, class_name: 'User'
  belongs_to :reviewing_user, class_name: 'User'

  scope :by_article_first_comment_id, ->(policy) {
    self.where('comments.id = ?', policy.dig(:scope, :message))
  }

  scope :by_article_id, ->(policy) {
    article = Article.find(policy.dig(:scope, :message))
    Comment.where(article: article)
  }

  scope :by_author_id_for_comment, ->(policy) {
    self.where('comments.author_id = ?', policy.dig(:scope, :message))
  }

  scope :by_comment_id, ->(policy) {
    self.where('comments.id = ?', policy.dig(:scope, :message))
  }

  # scope :index_scope, ->(policy) {
  #   self.all
  # }
  #
  # scope :show_scope, ->(policy) {
  #   self.all
  # }

end
