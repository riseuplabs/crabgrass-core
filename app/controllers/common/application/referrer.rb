#
# These are used in order to help make it easier to decide which
# thing is selected (for example, when showing navigation lists)
#
# for example:
#
#   active = controller?(:requests) and action?(:pending, :open)
#

require 'cgi'

module Common::Application::Referrer
  def self.included(base)
    base.class_eval do
      helper_method :referrer_params
      helper_method :referrer
    end
  end

  protected

  #
  # returns a hash for the query part of the referrer
  #
  def referrer_params
    @referrer_params ||= begin
      hsh = HashWithIndifferentAccess.new
      CGI.parse(referrer.sub(/^.*\?/, '')).each do |key, value|
        hsh[key] = value.first if value.is_a? Array
      end
      hsh
    end
  end

  #
  # returns the url of the HTTP Referrer (aka Referer).
  #
  def referrer
    @referrer ||= begin
      if request.env['HTTP_REFERER'].empty?
        '/'
      else
        raw = request.env['HTTP_REFERER']
        server = request.host_with_port
        prot = request.protocol
        if raw.starts_with?("#{prot}#{server}/")
          raw.sub(/^#{prot}#{server}/, '').sub(/\/$/, '')
        else
          '/'
        end
      end
    end
  end
end
