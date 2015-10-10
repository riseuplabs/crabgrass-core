#
# A user <> user association, where friendship.user is a friend of friendship.contact.
#
# Currently, every Friendship record implies a twin going the other way.
#

class User::Friendship < User::Relationship
end

