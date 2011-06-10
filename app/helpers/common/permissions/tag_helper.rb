#
#
# Setting permissions works with a number of ajaxy checkboxes we define here.
#
#

module Common::Permissions::TagHelper

  def permission_lock_tag(context, lock, keys)
    content_tag :ul, :class => '', :id => "keys_for_#{lock}" do
      keys.collect do |key|
        permission_key_tag(context, lock, key)
      end
    end
  end

  def permission_key_tag(context, lock, key)
    name    = "#{key.holder.to_sym}_#{lock}"
    label   = label_for_holder(key.holder)
    url     = switch_url(context, key.holder)
    options = switch_options(key, lock)
    spinbox_tag(name, label, url, options)
  end

  private

  def label_for_holder(holder)
    case holder
    when Symbol, String
      holder
    else
      holder.display_name
    end
  end

  def switch_url(context, holder)
    code = ActsAsLocked::Key.code_for_holder(holder)
    case context
      when :me
        me_permission_path(code)
      when Group
        group_permission_path(context, code)
    end
  end

  def switch_options(key, lock)
    checked = key.opens? lock
    options = {:checked => checked,
      :with => "'#{lock}=' + '#{!checked}'",
      :method => 'put'
    }
  end
end
