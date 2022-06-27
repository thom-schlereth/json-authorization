class TagResource < JSONAPI::Resource
  include JSONAPI::Authorization::PunditScopedResource

  has_one :taggable, polymorphic: true, always_include_linkage_data: true
end
