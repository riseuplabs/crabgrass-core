
SearchFilter.new('/ascending/:column/') do
  query do |query, column|
    column = query.cleanup_sort_column(column)
    query.add_order("#{column} ASC")
  end
end
