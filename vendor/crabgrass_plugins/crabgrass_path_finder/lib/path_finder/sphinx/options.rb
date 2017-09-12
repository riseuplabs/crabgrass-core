#
# =PathFinder::Sphinx::Options
#
# Callback functions for PathFinder::Options in case of a Sphinx backend.
#
# The callback functions populate the arrays with query parts for options.
# They are called from resolve_options in PathFinder::FindByPath
#
#
module PathFinder::Sphinx::Options
  def self.options_for_me(_path, options)
    options
  end

  def self.options_for_public(_path, options)
    options.merge(public: true)
  end

  def self.options_for_user(_path, options)
    user = options[:callback_arg_user]
    user_id = user.is_a?(User) ? user.id : user.to_i

    options.merge(public: true,
                  secondary_user_ids: [user_id])
  end

  # pass :committees => false to exclude sub-committees from the results.
  def self.options_for_group(_path, options)
    group = options[:callback_arg_group]
    group_ids = if group.is_a?(Group)
                  if options[:committees] == false
                    [group.id]
                  else
                    group.group_and_committee_ids
                              end
                else
                  [group.to_i]
                end

    options.merge(public: true,
                  secondary_group_ids: group_ids)
  end
end
