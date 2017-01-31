module User::Tags
  extend ActiveSupport::Concern

  included do
    serialize_as IntArray, :tag_id_cache
    initialized_by :update_tag_cache, :tag_id_cache
  end

  def tags
    ActsAsTaggableOn::Tag.where(id: tag_id_cache)
  end
end
