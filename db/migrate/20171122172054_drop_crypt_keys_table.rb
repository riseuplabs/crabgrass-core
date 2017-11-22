class DropCryptKeysTable < ActiveRecord::Migration
  def up
    drop_table :crypt_keys
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
