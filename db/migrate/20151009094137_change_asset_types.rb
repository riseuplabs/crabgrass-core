class ChangeAssetTypes < ActiveRecord::Migration
  def up
    Asset.connection.execute <<-EOSQL
    UPDATE assets
    SET type = REPLACE(type, 'Asset', '')
    EOSQL
  end

  def down
    Activity.connection.execute <<-EOSQL
    UPDATE assets
    SET type = CONCAT(type, 'Asset')
    EOSQL
  end
end
