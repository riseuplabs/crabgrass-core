#
# requires that the method 'key_holder_path(holder_code)' be defined.
# this method should return a path to a controller that responds to 'update'
# and takes holder_id as params[:id]. the remainder of the params are attributes
# for the key (that belongs to holder and castle).
#

module ActsAsLockedHelper

  def permission_lock_tag(lock, keys)
    content_tag :ul, :class => '', :id => "keys_for_#{lock}" do
      keys.collect do |key|
        permission_key_tag(lock, key) if key.allowed_for?(lock)
      end
    end
  end

  def permission_key_tag(lock, key)
    name    = "#{key.holder.to_sym}_#{lock}"
    label   = permission_holder_label(key.holder)
    url     = key_holder_path(key.keyring_code)
    options = checkbox_options(key, lock)
    spinbox_tag(name, label, url, options)
  end

  def permission_lock_label(lock)
    "may_#{lock}".to_sym.t
  end

  def permission_lock_info(lock)
   ""
   #"user_profile_description_may_#{lock}".to_sym.t
  end

  def permission_holder_label(holder)
    case holder
    when Symbol, String
      holder.tcap
    else
      holder.to_sym.tcap
    end
  end

  def permission_holder_info(holder)
    case holder
    when Symbol, String
      I18n.t(holder.to_s + '_description')
    else
      I18n.t(holder.to_sym.to_s + '_description')
    end
  end

  private

  def checkbox_options(key, lock)
    checked = key.opens? lock
    options = {:checked => checked,
      :with => "'#{lock}=' + '#{!checked}'",
      :method => 'put'
    }
  end

end
