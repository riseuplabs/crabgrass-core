module StarsHelper
  # hash that when used in haml will result in stars_count stars displayed
  # in the node:
  # {data: {stars: 23}}
  def stars_for(starred)
    starred.respond_to?(:stars_count) ? { data: { stars: starred.stars_count } } : {}
  end
end
