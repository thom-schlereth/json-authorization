class CommentResource < JSONAPI::Resource
  include JSONAPI::Authorization::PunditScopedResource

  has_many :tags, acts_as_set: true, exclude_links: :default
  has_one :article, merge_resource_records: false
  has_one :reviewer, relation_name: "reviewing_user", class_name: "User"
end
