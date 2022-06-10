class CommentResource < JSONAPI::Resource
  include JSONAPI::Authorization::PunditScopedResource

  has_many :tags
  has_one :article, merge_resource_records: false, merge_resource_records: false
  has_one :reviewer, relation_name: "reviewing_user", class_name: "User"
end
