
SearchFilter.new('/descending/:column/') do
  query do |query, column|
    column = query.cleanup_sort_column(column)
    query.add_order("#{column} DESC")
  end
end
