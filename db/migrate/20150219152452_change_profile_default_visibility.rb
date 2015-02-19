class ChangeProfileDefaultVisibility < ActiveRecord::Migration
  def up
    change_table :profiles do |profiles|
      profiles.change :may_see, :boolean, default: nil
    end
  end

  def down
    change_table :profiles do |profiles|
      profiles.change :may_see, :boolean, default: true
    end
  end
end
