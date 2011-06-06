#
#
# Setting permissions works with a number of ajaxy checkboxes we define here.
#
#

module Common::Permissions::TagHelper

  def permission_switch_tag(context, key, lock)
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
