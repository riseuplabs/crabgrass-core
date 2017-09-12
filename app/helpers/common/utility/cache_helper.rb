module Common::Utility::CacheHelper
  def entity_cache_key(entity, options = {})
    options.reverse_merge! version: entity.version,
                           updated_at: entity.updated_at.to_i,
                           path: nil,
                           authenticity_token: nil,
                           _context: nil
    options.reverse_merge(params).values.compact.join('-')
  end

  def group_cache_key(group, options = {})
    options.reverse_merge! lang: session[:language_code],
                           may_admin: current_user.may?(:admin, group),
                           access: @access
    entity_cache_key(group, options)
  end

  def me_cache_key
    params.merge user_id: current_user.id,
                 version: current_user.version,
                 path: nil,
                 authenticity_token: nil
  end

  def menu_cache_key(options = {})
    options.reverse_merge! site: current_site.id,
                           user: current_user.cache_key,
                           v: 2
    cache_key 'menu', options
  end

  # example input: cache_key('wiki', :version => 1, :editable => false)
  # output "wiki/version=1&editable=false"
  def cache_key(path, options = {})
    path = "#{path}/" + options.to_query
  end
end
