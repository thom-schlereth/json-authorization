class Comment < ActiveRecord::Base
  has_many :tags, as: :taggable
  belongs_to :article
  belongs_to :author, class_name: 'User'
  belongs_to :reviewing_user, class_name: 'User'

  scope :index_scope, ->(policy) {
    self.all
  }

  scope :show_scope, ->(policy) {
    self.all
  }

end
