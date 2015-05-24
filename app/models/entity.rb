#
# Much to my regret, there is no superclass of users and groups.
#
# In many places, we treat users and groups interchangeably. This class attempts
# to make that a little easier.
#
# TODO: move parse recipients and entity name validation to this class.
#

class Entity

  # returns a user or group with +name+ and throws a not found exception otherwise.
  def self.find_by_name!(name)
    User.where(login: name).first!
  rescue ActiveRecord::RecordNotFound
    Group.where(name: name).first!
  end

end
