class ReduceVarcharLengthForIndexedColumns < ActiveRecord::Migration
  def up
    change_column :castle_gates_keys, :castle_type, :string, limit: 191
    change_column :groups, :name, :string, limit: 191
    change_column :pages, :type, :string, limit: 191
    change_column :pages, :data_type, :string, limit: 191
    change_column :pages, :name, :string, limit: 191
    change_column :pages, :owner_name, :string, limit: 191
    change_column :profiles, :entity_type, :string, limit: 191
    change_column :thumbnails, :parent_type, :string, limit: 191
    change_column :users, :login, :string, limit: 191
    change_column :taggings, :taggable_type, :string, limit: 191
    change_column :taggings, :tagger_type, :string, limit: 191
    ActiveRecord::Base.connection.execute "ALTER TABLE tags MODIFY name varchar(191) CHARACTER SET utf8 COLLATE utf8_bin;"
    change_column :notices, :noticable_type, :string, limit: 191
  end

  def down
    change_column :castle_gates_keys, :castle_type, :string, limit: 255
    change_column :groups, :name, :string, limit: 255
    change_column :pages, :type, :string, limit: 255
    change_column :pages, :data_type, :string, limit: 255
    change_column :pages, :name, :string, limit: 255
    change_column :pages, :owner_name, :string, limit: 255
    change_column :profiles, :entity_type, :string, limit: 255
    change_column :thumbnails, :parent_type, :string, limit: 255
    change_column :users, :login, :string, limit: 255
    change_column :taggings, :taggable_type, :string, limit: 255
    change_column :taggings, :tagger_type, :string, limit: 255
    ActiveRecord::Base.connection.execute "ALTER TABLE tags MODIFY name varchar(255) CHARACTER SET utf8 COLLATE utf8_bin;"
    change_column :notices, :noticable_type, :string, limit: 255
  end
end
