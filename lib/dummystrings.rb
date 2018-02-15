#
# here lies translation keys that are important but do not actually appear anywhere in the code.
#
# for example: I18n.t @request.class.name.underscore
#
# for adding keys that are nested, you must add them in the following format:
# for example: I18n.t("autocomplete.placeholder.enter_name_of_group_or_person")
#
# for adding keys that are not nested, add them in the following format:
# for example: :friends.t
#
# otherwise the rake task cg:i18n: won't work properly
#

# requests:

:request_to_destroy_our_group.t
:request_to_join_us_via_email.t
:request_to_join_you.t
:request_to_remove_user.t

# permissions:
# appear as:
# may_#{lock}_label
# may_#{lock}_description

:may_pester_description.t
:may_request_contact_description.t
:may_request_membership_description.t
:may_see_contacts_description.t
:may_see_groups_description.t
:may_view_description.t

:may_pester_label.t
:may_request_contact_label.t
:may_see_contacts_label.t
:may_see_groups_label.t
:may_view_label.t

# filter

:filter_group_description.t
:filter_tag_description.t
:filter_user_description.t

# pages

:all_pages.t
:my_pages.t
:popular_pages.t

# page display

:asset_page_display.t
:discussion_page_display.t
:ranked_vote_page_display.t
:rate_many_page_display.t
:task_list_page_display.t
:survey_page_display.t
:wiki_page_display.t

# page description

:asset_page_description.t
:discussion_page_description.t
:ranked_vote_page_description.t
:rate_many_page_description.t
:task_list_page_description.t
:wiki_page_description.t

# page group

:page_group_media.t
:page_group_planning.t
:page_group_text.t
:page_group_vote.t

# wiki

:create_private_group_wiki.t
:create_public_group_wiki.t
:private_group_wiki.t
:public_group_wiki.t

# more description

:created_by_user_description.t
:friends_description.t
:peers_description.t
:public_description.t

# days

:sunday.t
:monday.t
:tuesday.t
:wednesday.t
:thursday.t
:friday.t
:saturday.t

# generic

:advanced.t
:properties.t
:friends.t
