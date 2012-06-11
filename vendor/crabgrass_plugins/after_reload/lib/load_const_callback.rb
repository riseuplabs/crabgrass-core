#
# module to track the callbacks
#

module LoadConstCallback
  mattr_accessor :callbacks
  self.callbacks = {}

  def self.add(model, &block)
    model_name = model.to_s
    self.callbacks[model_name] ||= []
    self.callbacks[model_name] << block
    yield model
  end

  def self.fire(model)
    model_name = model.to_s
    if self.callbacks[model_name]
      self.callbacks[model_name].each do |block|
        block.call(model)
      end
    end
  end
end
