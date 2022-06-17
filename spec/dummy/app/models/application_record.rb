class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  scope :by_article_id, ->(policy) {
    self.all
  }

  scope :by_article_first_comment_id, ->(policy) {
    self.all
  }

  scope :by_author_id_for_comment, ->(policy) {
    self.all
  }




end
