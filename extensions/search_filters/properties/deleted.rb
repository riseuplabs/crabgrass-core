SearchFilter.new('/deleted/') do
  query do |query|
    query.set_flow_constraint(:deleted)
  end

  #
  # ui
  #

  self.section = :properties
  self.path_order = 1
  self.singleton = true

  label do |_opts|
    :deleted.t
  end
end
