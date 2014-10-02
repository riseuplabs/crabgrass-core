# use the context route for this model

module ContextRoutes
  def model_name
    @_model_name ||= super.tap do |name|
      name.singleton_class.send(:define_method, :param_key) { 'context_id' }
      name.singleton_class.send(:define_method, :singular_route_key) { 'context' }
    end
  end
end
