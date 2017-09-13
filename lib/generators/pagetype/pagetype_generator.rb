class PagetypeGenerator < Rails::Generators::NamedBase
  desc 'This generator creates a new pagetype and registers it in crabgrass'
  source_root File.expand_path('../templates', __FILE__)

  def create_crabgrass_engine
    template 'crabgrass_engine.rb.erb',
             "extensions/pages/#{name}_page/lib/crabgrass_#{name}_page.rb"
  end

  def create_page_class
    template 'page.rb.erb',
             "extensions/pages/#{name}_page/app/models/#{name}_page.rb"
  end

  def create_controller_class
    template 'page_controller.rb.erb',
             "extensions/pages/#{name}_page/app/controllers/#{name}_page_controller.rb"
  end

  def create_view
    create_file "extensions/pages/#{name}_page/app/views/#{name}_page/show.html.haml"
  end

  def add_translation
    append_to_file 'config/locales/en/pages.yml', <<-EOT
  #{name}_page_description: "Please adjust this translation in config/locales/en/pages.yml!"
  #{name}_page_display: "#{class_name}"
    EOT
  end

  def activate_page_type
    gsub_file 'config/crabgrass/crabgrass.development.yml',
              "available_page_types:\n",
              "available_page_types:\n  - #{class_name}Page\n"
    # remove duplicates
    gsub_file 'config/crabgrass/crabgrass.development.yml',
              "\n  - #{class_name}Page\n  - #{class_name}Page\n",
              "\n  - #{class_name}Page\n"
  end
end
