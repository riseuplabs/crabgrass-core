class AdoptThumbnailParentType < ActiveRecord::Migration
  def up
    changes.each { |k, v| change_asset(k, v) }
  end

  def down
    changes.each { |k, v| change_asset(v, k) }
  end

  protected

  def change_asset(from, to)
    Thumbnail.connection.execute <<-"EOSQL"
      UPDATE thumbnails
      SET parent_type = '#{to}'
      WHERE parent_type = '#{from}'
    EOSQL
  end

  def changes
    { 'AudioAsset' => 'Asset::Audio',
      'DocAsset' => 'Asset::Doc',
      'GifAsset' => 'Asset::Gif',
      'ImageAsset' => 'Asset::Image',
      'PngAsset' => 'Asset::Png',
      'SpreadsheetAsset' => 'Asset::Spreadsheet',
      'SvgAsset' => 'Asset::Svg',
      'TextAsset' => 'Asset::Text' }
  end
end
