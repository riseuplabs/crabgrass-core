class IndexPagesOnData < ActiveRecord::Migration
  def self.up
    add_index :pages, [:data_id, :data_type]
  end

  def self.down
    remove_index :pages, [:data_id, :data_type]
  end
end
