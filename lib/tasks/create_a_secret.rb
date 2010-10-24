task :create_a_secret do
  path = File.join(RAILS_ROOT, "config/crabgrass/secret.txt")
  `rake -s secret > #{path}`
end
