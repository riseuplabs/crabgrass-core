#
# Make subclasses use the same routes as the super class:
#
# class Page
#   extend RouteInheritance
# end
#
# class DiscussionPage < Page
# end
#
# url_for DiscussionPage.new
#  -> /pages
#
# taken from https://gist.github.com/sj26/5843855.
#

module RouteInheritance
  def model_name
    @_model_name ||= super.tap do |name|
      unless self == base_class
        the_base_class = base_class
        %w[param_key singular_route_key route_key].each do |key|
          name.singleton_class.send(:define_method, key) { the_base_class.model_name.public_send(key) }
        end
      end
    end
  end
end
