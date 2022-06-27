class Tag < ApplicationRecord
  belongs_to :taggable, polymorphic: true

  scope :by_tag_not_found, ->(policy) {
    where.not(policy.dig(:scope, :tag_id))
  }

end
