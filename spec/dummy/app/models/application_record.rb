class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  scope :by_article_external_id, ->(policy) {
    self.all
  }

  scope :by_article_first_comment_id, ->(policy) {
    self.all
  }

  scope :by_articles_first_comment_id, ->(policy) {
    self.all
  }

  scope :by_author_id_for_comment, ->(policy) {
    self.all
  }

  scope :by_articles_not_found, ->(policy) {
    self.all
  }

  scope :by_tag_not_found, ->(policy) {
    self.all
  }

  scope :by_comments_not_found, ->(policy) {
    self.all
  }

  scope :by_comment_id, ->(policy) {
    self.all
  }

end
