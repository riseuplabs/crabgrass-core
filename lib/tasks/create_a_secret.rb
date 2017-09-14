task :create_a_secret do
  puts 'Crabgrass now uses the default rails4 mechanism for storing secrets.'
  puts "Please run 'rake secret' and copy the key to the line for your"
  puts 'environment in config/secrets.yml.'
  puts 'For production you can also set the environments SECRET_KEY_BASE.'
end
