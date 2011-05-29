#
#
# Setting permissions works with a number of ajaxy checkboxes we define here.
#
#

module Common::Permissions::TagHelper

  def permission_switch_tag(context, holder, lock, checked = true)
    label = case holder
      when Symbol
        holder
      else
        holder.display_name
    end
    code = ActsAsLocked::Key.code_for_holder(holder)
    url = case context
      when :me
        me_permission_path(code)
      when Group
        group_permission_path(context, code)
    end
    options = {:checked => checked,
      :with => "'#{lock}=' + '#{!checked}'",
      :method => 'put'
    }
    name = holder.to_sym.to_s + '_' + lock.to_s
    spinbox_tag(name, label, url, options)
  end

end
