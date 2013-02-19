# Be sure to restart your server when you modify this file.

if defined?(ActiveRecord)
  # Store the full class name (including module namespace) in STI type column.
  # For crabgrass, this needs to be false. The new default in rails is true,
  # but cg needs it set to false.
  ActiveRecord::Base.store_full_sti_class = false
end
