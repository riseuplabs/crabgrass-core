#
# This gives us the more flexible handling of etags from rails4
# plus a fix for https://github.com/rails/rails/issues/19056
#

module ActionDispatch::Http::Cache::Request

  def etag_matches?(etag)
    if etag
      etag = etag.gsub(/^\"|\"$/, "").sub('-gzip', "")
      if_none_match_etags.include?(etag)
    end
  end

  def if_none_match_etags
    (if_none_match ? if_none_match.split(/\s*,\s*/) : []).collect do |etag|
      etag = etag.gsub(/^\"|\"$/, "").sub('-gzip', "")
    end
  end

end
