module ActionView
  module Template::Handlers
    class RJS
      # Default format used by RJS.
      class_attribute :default_format
      # see https://github.com/mileszs/wicked_pdf/pull/627
      self.default_format = Mime[:js]

      def call(template)
        "update_page do |page|;#{template.source}\nend"
      end
    end
  end
end

