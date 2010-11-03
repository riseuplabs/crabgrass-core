class ActsAsPermissiveMigrationGenerator < Rails::Generator::Base
  def manifest
    record do |m|
      m.migration_template 'migration.rb', File.join('db', 'migrate'), :migration_file_name => 'install_acts_as_permissive'
    end
  end
end
