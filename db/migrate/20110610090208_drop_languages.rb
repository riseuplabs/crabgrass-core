class DropLanguages < ActiveRecord::Migration
  def self.up
    drop_table :languages
  end

  def self.down
    create_table :languages do |t|
      t.string :name
      t.string :code
      t.timestamps
    end
    add_index(:languages, [:name,:code], { :name => 'languages_index', :unique => true })
    Language.create! :name => "English", :code => 'en'
  end
end
