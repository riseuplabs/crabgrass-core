module Utility::UrlHelper

  protected

  #
  # lifted from active_record's routing.rb
  #
  # Build a query string from the keys of the given hash. If +only_keys+
  # is given (as an array), only the keys indicated will be used to build
  # the query string. The query string will correctly build array parameter
  # values.
  def build_query_string(hash, only_keys=nil)
    elements = []

    only_keys ||= hash.keys

    only_keys.each do |key|
      value = hash[key] or next
      key = CGI.escape key.to_s
      if value.class == Array
        key <<  '[]'
      else
        value = [ value ]
      end
      value.each { |val| elements << "#{key}=#{CGI.escape(val.to_param.to_s)}" }
    end

    query_string = "?#{elements.join("&")}" unless elements.empty?
    query_string || ""
  end

end

