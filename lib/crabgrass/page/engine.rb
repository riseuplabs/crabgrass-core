module Crabgrass::Page
  module Engine
    extend ActiveSupport::Concern

    module ClassMethods
      def register_page_type(name, options)
        name = name.to_s
        initializer "crabgrass_page.register_#{name.underscore}",
          before: "crabgrass_page.freeze_pages" do |_app|
          ClassRegistrar.add name, options
        end
      end
    end

  end
end
