# This migration comes from acts_as_taggable_on_engine (originally 2)
class AddMissingUniqueIndices < ActiveRecord::Migration
  def self.up
    add_index :tags, :name, unique: true

    remove_index 'taggings', name: 'tag_id_index'
    remove_index 'taggings', name: 'taggable_id_index'
    add_index :taggings,
              %i[tag_id taggable_id taggable_type context tagger_id tagger_type],
              unique: true, name: 'taggings_idx'
  end

  def self.down
    remove_index :tags, :name

    remove_index :taggings, name: 'taggings_idx'
    add_index :taggings, :tag_id,
              name: 'tag_id_index'
    add_index :taggings, %i[taggable_id taggable_type context],
              name: 'taggable_id_index'
  end
end
