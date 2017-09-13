#
# This class allows differenctiating some configuration settings based on
# the domain of the current request.
# So the same server could respond with a different theme, title, etc. if
# contacted via different domain names.
#
# We used to run multiple crabgrass sites on one install - separating
# the data into different networks.
# We're not doing this anymore and we only want to keep the ability to
# change some properties.
#
# This used to be an ActiveRecord::Base subclass and we stored the values
# in the database. But since we do not have an editor for these values anymore
# and expect people running a crabgrass install to be able to write config
# files we may as well use plain ruby now.

class Site
  def initialize(domain = nil)
    @domain = domain
  end

  def self.for_domain(domain)
    new domain
  end

  def self.default
    new
  end

  def self.proxy_to_conf(*attributes)
    attributes.each do |attribute|
      define_method(attribute) do
        value = config[attribute.to_s.sub(/\?$/, '')]
        # note: using || below would overwrite falsy values
        value.nil? ? Conf.send(attribute) : value
      end
    end
  end

  proxy_to_conf :title, :domain, :theme,
                :pagination_size, :default_language, :login_redirect_url,
                :email_sender, :email_sender_name, :dev_email,
                :show_exceptions

  protected

  def config
    Conf.sites[@domain] || {}
  end
end
