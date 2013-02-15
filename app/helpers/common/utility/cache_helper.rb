module Common::Utility::CacheHelper

  def entity_cache_key(entity, options={})
    params.merge(:version => entity.version, :updated_at => entity.updated_at.to_i,
        :path => nil, :authenticity_token => nil).merge(options)
  end

  def group_cache_key(group, options={})
    may_admin = current_user.may?(:admin, group)
    entity_cache_key(group, :lang => session[:language_code], :may_admin => may_admin, :access => @access).merge(options)
  end

  def me_cache_key
    params.merge(:user_id => current_user.id, :version => current_user.version, :path => nil, :authenticity_token => nil)
  end

  def menu_cache_key(options={})
    current_site_key = current_site.id ? "current_site="+current_site.id.to_s+"&" : ""
    "menu/#{current_site_key}menu_id=#{options[:menu_id]}&user_id=#{current_user.id}&version=#{current_user.version}"
  end

  # example input: cache_key('wiki', :version => 1, :editable => false)
  # output "wiki/version=1&editable=false"
  def cache_key(path, options = {})
    path = "#{path}/"
    key_pairs = []
    options.each do |k, v|
      key_pairs << "#{k}=#{v}"
    end
    path + key_pairs.sort.join('&')
  end

end
