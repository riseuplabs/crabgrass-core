#
#
# Sites are stored in the db, but the crabgrass.*.yml file determines
# which sites are active and what the admin group is for each site. This
# is kept in the config file for security reasons and to make it easy to
# enable/disable sites.
#

ids = []
begin
  Conf.sites.each do |site_conf|
    site = Site.find_by_name(site_conf['name'])
    if site.nil?
      if Site.count == 0
        puts 'Skipping site configuration: database has no sites.'
        raise Exception.new('skip sites')
      else
        puts <<-EOMSG
          ERROR (#{Conf.configuration_filename}):
          Site name '#{site_conf['name']}' not found in database!
          Available site names are:
            #{Site.find(:all).collect(&:name).inspect}
          To create a site, run:
            rake cg:site:create NAME=<name> RAILS_ENV=<env>
        EOMSG
      end
    end
  end
rescue Exception => exc
  # skip the sites initialization if something goes wrong. Likely, the
  # problem is that the sites db is not yet set up.
end

# an array of id numbers of sites that are enabled. If a site does not
# have an id in this array, then we pretend that the site doesn't exist.
Conf.enabled_site_ids = ids.freeze
