module Formy
  module Helper
    def formy(form_type, options = {})
      options[:annotate] = Rails.env == 'development'
      class_string = 'Formy::' + form_type.to_s.camelize
      form = class_string.constantize.new(options)
      form.open
      yield form
      form.close
      form.to_s.html_safe
    end
  end
end
