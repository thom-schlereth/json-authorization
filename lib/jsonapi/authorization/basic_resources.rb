class JSONAPI::BasicResource

  def self.resource_for_polymorphic(type, context)
    type = type.to_s.underscore
    type_with_module = type.start_with?(module_path) ? type : module_path + type
    # binding.pry
    resource_name = _resource_name_from_type(type_with_module)
    resource = resource_name.safe_constantize if resource_name
    if resource.nil?
      fail NameError, "JSONAPI: Could not find resource '#{type}'. (Class #{resource_name} not found)"
    end
    resource
  end
end
