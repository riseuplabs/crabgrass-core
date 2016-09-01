class ChangeActivityTypes < ActiveRecord::Migration
  def up
    Activity.connection.execute <<-EOSQL
    UPDATE activities
    SET type = REPLACE(type, 'Activity', '')
    EOSQL
  end

  def down
    Activity.connection.execute <<-EOSQL
    UPDATE activities
    SET type = CONCAT(type, 'Activity')
    EOSQL
  end
end
