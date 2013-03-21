#
#
# This helper contains backported functionality from later rails versions
#
#

module Common::Utility::BackportsHelper

  #
  # Rails 3.1
  #

  def safe_join(array, sep=$,)
    sep ||= "".html_safe
    sep = ERB::Util.html_escape(sep)

    array.map { |i| ERB::Util.html_escape(i) }.join(sep).html_safe
  end


end
