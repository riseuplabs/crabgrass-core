module GroupsPermission
  prefix = File.dirname(__FILE__)
  path = prefix + '/group'
  file_paths = Dir.glob(path + '/*.rb').collect { |f| f.chomp('.rb') }
  file_paths.each do |file_path|
    relative_path = file_path.sub(/^#{Regexp.escape(prefix)}/, '')
    include(relative_path.camelize.constantize)
  end
end
