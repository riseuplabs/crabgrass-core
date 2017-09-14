module AuthenticatedTestHelper

  def content_type(type)
    @request.env['Content-Type'] = type
  end

  def accept(accept)
    @request.env['HTTP_ACCEPT'] = accept
  end

  def reset!(*instance_vars)
    instance_vars = %i[controller request response] unless instance_vars.any?
    instance_vars.collect! { |v| "@#{v}".to_sym }
    instance_vars.each do |var|
      instance_variable_set(var, instance_variable_get(var).class.new)
    end
  end
end
