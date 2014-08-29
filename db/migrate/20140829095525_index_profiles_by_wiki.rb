#
# when loading a wiki we also fetch its context (page or group)
# This may happen through profiles. So we should get the profile
# belonging to a wiki quickly.
#
class IndexProfilesByWiki < ActiveRecord::Migration
  def self.up
    add_index :profiles, [:wiki_id, :entity_id], :name => "profiles_for_wikis"
  end

  def self.down
    remove_index :profiles, :name => "profiles_for_wikis"
  end
end
