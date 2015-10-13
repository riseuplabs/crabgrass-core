class ChangeUserGhostType < ActiveRecord::Migration
  def up
    User.connection.execute <<-EOSQL
    UPDATE users
    SET type = 'Ghost'
    WHERE type = 'UserGhost'
    EOSQL
  end

  def down
    User.connection.execute <<-EOSQL
    UPDATE users
    SET type = 'UserGhost'
    WHERE type = 'Ghost'
    EOSQL
  end
end
