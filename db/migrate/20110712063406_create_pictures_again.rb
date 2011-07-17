#
# in ancient times, we had a pictures table, but it was destroyed
# a long time ago. now we have a pictures table again.
#

class CreatePicturesAgain < ActiveRecord::Migration
  def self.up
    create_table :pictures do |t|
      t.string :content_type
      t.string :caption
      t.string :credit
      t.string :dimensions
      t.boolean :public
    end
  end

  def self.down
    drop_table :pictures
  end
end

