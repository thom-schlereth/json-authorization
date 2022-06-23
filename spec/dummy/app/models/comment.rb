class Comment < ApplicationRecord
  has_many :tags, as: :taggable
  belongs_to :article
  belongs_to :author, class_name: 'User'
  belongs_to :reviewing_user, class_name: 'User'

  scope :by_articles_first_comment_id, ->(policy) {
    self.where('comments.id = ?', policy.dig(:scope, :comment_id))
  }

  scope :by_article_first_comment_id, ->(policy) {
    self.where('comments.id = ?', policy.dig(:scope, :comment_id))
  }

  scope :by_comment_id, ->(policy) {
    self.where('comments.id = ?', policy.dig(:scope, :comment_id))
  }

  scope :by_comments_not_found, ->(policy) {
    where.not(id: policy.dig(:scope, :comment_ids))
  }

end
