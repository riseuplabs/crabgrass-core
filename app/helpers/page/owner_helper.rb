module Page::OwnerHelper
  protected

  def change_page_owner
    if may_admin_page?
      html = render 'page/details/change_owner'
      link_to_modal :edit.t,
                    html: html,
                    title: :page_create_owner.tcap,
                    icon: 'pencil'
    end
  end

  #
  # returns option tags usable in a select menu to choose a page owner.
  #
  # There are four types of entries:
  #
  #  (1) groups the user is a (direct or indirect) member of
  #  (2) the user
  #  (3) 'none' if !Conf.ensure_page_owner?
  #  (4) the current owner, even if it doesn't meet one of the other criteria.
  #
  # required options:
  #
  #  :selected     -- the item to make selected (either string or group object)
  #
  def options_for_page_owner(options = {})
    options_for_select_group(
      options.merge(
        include_me: true,
        include_committees: true,
        include_none: !Conf.ensure_page_owner?
      )
    )
  end
end
