class AddAverageColorToPictures < ActiveRecord::Migration
  def self.up
    add_column :pictures, :average_color, :string
  end

  def self.down
    remove_column :pictures, :average_color
  end
end
