class ThumbnailParentTypeIsAsset < ActiveRecord::Migration
  def up
    Thumbnail.connection.execute <<-"EOSQL"
      UPDATE thumbnails
        SET parent_type = 'Asset'
        WHERE parent_type <> 'Asset::Version'
    EOSQL
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
