ThinkingSphinx::Index.define 'page/terms', with: :active_record,
                                           delta: ThinkingSphinx::Deltas::DelayedDelta do
  ## text fields ##

  # general fields
  indexes :title,     sortable: true
  indexes :page_type, sortable: true
  indexes :tags
  indexes :body
  indexes :comments

  # denormalized names
  indexes :created_by_login, sortable: true
  indexes :updated_by_login, sortable: true
  indexes :owner_name,       sortable: true

  ## attributes ##

  # timedates
  has :page_created_at
  has :page_updated_at

  # ids
  has :created_by_id
  has :updated_by_id
  has :owner_id

  # counts
  has :stars_count

  # flags and access
  has :resolved
  has :access_ids, multi: true, type: :integer
  has :media, multi: true, type: :integer
  has :flow
end
