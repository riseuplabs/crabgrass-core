#
# limit is not compatible with pagination.
# i am not sure we even want to support it.
#

SearchFilter.new('/limit/:limit_count') do

  query do |query, limit_count|
    limit = limit_count.to_i
    # don't allow really large limits
    if limit < 512
      query.add_limit(limit)
    end
  end

end
