# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20181114101916) do

  create_table "asset_versions", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci" do |t|
    t.integer "asset_id"
    t.integer "version"
    t.integer "parent_id"
    t.string "content_type"
    t.string "filename"
    t.string "thumbnail"
    t.integer "size"
    t.integer "width"
    t.integer "height"
    t.integer "page_id"
    t.datetime "created_at"
    t.string "versioned_type"
    t.datetime "updated_at"
    t.integer "user_id"
    t.text "comment"
    t.index ["asset_id"], name: "index_asset_versions_asset_id"
    t.index ["page_id"], name: "index_asset_versions_page_id"
    t.index ["parent_id"], name: "index_asset_versions_parent_id"
    t.index ["version"], name: "index_asset_versions_version"
  end

  create_table "assets", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci" do |t|
    t.string "content_type"
    t.string "filename"
    t.integer "size"
    t.integer "width"
    t.integer "height"
    t.string "type"
    t.integer "page_id"
    t.datetime "created_at"
    t.integer "version"
    t.integer "page_terms_id"
    t.boolean "is_attachment", default: false
    t.boolean "is_image"
    t.boolean "is_audio"
    t.boolean "is_video"
    t.boolean "is_document"
    t.datetime "updated_at"
    t.string "caption"
    t.datetime "taken_at"
    t.string "credit"
    t.integer "user_id"
    t.text "comment"
    t.index ["page_id"], name: "index_assets_page_id"
    t.index ["page_terms_id"], name: "pterms"
    t.index ["version"], name: "index_assets_version"
  end

  create_table "avatars", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci" do |t|
    t.binary "image_file_data", limit: 4294967295
    t.boolean "public", default: false
  end

  create_table "castle_gates_keys", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci" do |t|
    t.integer "castle_id"
    t.string "castle_type", limit: 191
    t.integer "holder_code"
    t.integer "gate_bitfield", default: 1
    t.index ["castle_id", "castle_type", "holder_code"], name: "index_castle_gates_by_castle_and_holder_code"
  end

  create_table "csp_reports", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci" do |t|
    t.text "document_uri"
    t.text "referrer"
    t.text "violated_directive"
    t.text "effective_directive"
    t.text "original_policy"
    t.text "blocked_uri"
    t.integer "status_code"
    t.text "ip"
    t.text "user_agent"
    t.boolean "report_only"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "custom_appearances", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci" do |t|
    t.text "parameters"
    t.integer "parent_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "masthead_asset_id"
    t.integer "favicon_id"
  end

  create_table "delayed_jobs", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci" do |t|
    t.integer "priority", default: 0
    t.integer "attempts", default: 0
    t.text "handler", limit: 16777215
    t.text "last_error", limit: 16777215
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string "locked_by"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "queue"
    t.index ["priority", "run_at"], name: "delayed_jobs_priority"
  end

  create_table "discussions", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci" do |t|
    t.integer "posts_count", default: 0
    t.datetime "replied_at"
    t.integer "replied_by_id"
    t.integer "last_post_id"
    t.integer "page_id"
    t.integer "commentable_id"
    t.string "commentable_type"
    t.index ["page_id"], name: "index_discussions_page_id"
  end

  create_table "external_videos", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci" do |t|
    t.string "media_key"
    t.string "media_url"
    t.string "media_thumbnail_url"
    t.text "media_embed"
    t.integer "page_terms_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "height", limit: 2
    t.integer "width", limit: 2
    t.integer "player", limit: 2
  end

  create_table "federatings", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci" do |t|
    t.integer "group_id"
    t.integer "network_id"
    t.integer "council_id"
    t.integer "delegation_id"
    t.datetime "created_at"
    t.index ["group_id", "network_id"], name: "gn"
    t.index ["network_id", "group_id"], name: "ng"
  end

  create_table "group_participations", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci" do |t|
    t.integer "group_id"
    t.integer "page_id"
    t.integer "access"
    t.boolean "static", default: false
    t.datetime "static_expires"
    t.boolean "static_expired", default: false
    t.integer "featured_position"
    t.index ["group_id", "page_id"], name: "index_group_participations"
    t.index ["page_id"], name: "index_group_participations_on_page_id"
  end

  create_table "groups", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci" do |t|
    t.string "name", limit: 191
    t.string "full_name"
    t.string "url"
    t.string "type"
    t.integer "parent_id"
    t.integer "council_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "avatar_id"
    t.string "style"
    t.string "language", limit: 5
    t.integer "version", default: 0
    t.integer "min_stars", default: 1
    t.integer "site_id"
    t.boolean "full_council_powers", default: false
    t.index ["name"], name: "index_groups_on_name"
    t.index ["parent_id"], name: "index_groups_parent_id"
  end

  create_table "memberships", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci" do |t|
    t.integer "group_id"
    t.integer "user_id"
    t.datetime "created_at"
    t.boolean "admin", default: false
    t.datetime "visited_at", default: "1000-01-01 00:00:00", null: false
    t.integer "total_visits", default: 0
    t.string "join_method"
    t.index ["group_id", "user_id"], name: "gu"
    t.index ["user_id", "group_id"], name: "ug"
  end

  create_table "migrations_info", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci" do |t|
    t.datetime "created_at"
  end

  create_table "notices", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci" do |t|
    t.string "type"
    t.integer "user_id"
    t.integer "avatar_id"
    t.text "data", limit: 16777215
    t.integer "noticable_id"
    t.string "noticable_type", limit: 191
    t.boolean "dismissed", default: false
    t.datetime "dismissed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["noticable_type", "noticable_id"], name: "index_notices_on_noticable_type_and_noticable_id"
    t.index ["user_id"], name: "index_notices_on_user_id"
  end

  create_table "page_access_codes", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci" do |t|
    t.string "code", limit: 10
    t.integer "page_id"
    t.integer "user_id"
    t.integer "access"
    t.datetime "expires_at"
    t.string "email"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["code"], name: "index_page_access_codes_on_code", unique: true
    t.index ["expires_at"], name: "index_page_access_codes_on_expires_at"
  end

  create_table "page_histories", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci" do |t|
    t.integer "user_id"
    t.integer "page_id"
    t.string "type"
    t.datetime "created_at"
    t.integer "item_id"
    t.string "item_type"
    t.datetime "notification_sent_at"
    t.datetime "notification_digest_sent_at"
    t.string "details"
    t.index ["page_id"], name: "index_page_histories_on_page_id"
    t.index ["user_id"], name: "index_page_histories_on_user_id"
  end

  create_table "page_terms", id: :integer, force: :cascade, options: "ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci" do |t|
    t.bigint "page_id"
    t.string "page_type"
    t.text "access_ids", limit: 16777215
    t.text "body", limit: 16777215
    t.text "comments", limit: 16777215
    t.text "tags"
    t.string "title"
    t.boolean "resolved"
    t.integer "rating"
    t.integer "contributors_count"
    t.integer "flow", default: 0
    t.string "created_by_login"
    t.string "updated_by_login"
    t.bigint "created_by_id"
    t.bigint "updated_by_id"
    t.datetime "page_updated_at"
    t.datetime "page_created_at"
    t.boolean "delta"
    t.string "media"
    t.integer "stars_count", default: 0
    t.string "owner_name"
    t.integer "owner_id"
    t.index ["access_ids", "tags"], name: "idx_fulltext", type: :fulltext
    t.index ["delta"], name: "index_page_terms_on_delta"
    t.index ["page_id"], name: "page_id"
  end

  create_table "page_tools", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci" do |t|
    t.integer "page_id"
    t.integer "tool_id"
    t.string "tool_type"
    t.index ["page_id", "tool_id"], name: "index_page_tools"
  end

  create_table "pages", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci" do |t|
    t.string "title"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "resolved", default: true
    t.boolean "public"
    t.integer "created_by_id"
    t.integer "updated_by_id"
    t.text "summary", limit: 16777215
    t.string "type", limit: 191
    t.integer "message_count", default: 0
    t.integer "data_id"
    t.string "data_type", limit: 191
    t.integer "contributors_count", default: 0
    t.string "name", limit: 191
    t.string "updated_by_login"
    t.string "created_by_login"
    t.integer "flow", default: 0
    t.integer "stars_count", default: 0
    t.integer "owner_id"
    t.string "owner_type"
    t.string "owner_name", limit: 191
    t.boolean "is_image"
    t.boolean "is_audio"
    t.boolean "is_video"
    t.boolean "is_document"
    t.integer "site_id"
    t.datetime "happens_at"
    t.integer "cover_id"
    t.index ["created_at"], name: "index_pages_on_created_at"
    t.index ["data_id", "data_type"], name: "index_pages_on_data_id_and_data_type"
    t.index ["flow"], name: "index_pages_on_flow"
    t.index ["name", "owner_id"], name: "index_pages_on_name"
    t.index ["owner_name"], name: "owner_name_4", length: { owner_name: 4 }
    t.index ["type"], name: "index_pages_on_type"
    t.index ["updated_at"], name: "index_pages_on_updated_at"
  end

  create_table "pgp_keys", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci" do |t|
    t.text "key"
    t.string "fingerprint"
    t.integer "user_id"
    t.datetime "expires"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "pictures", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci" do |t|
    t.string "content_type"
    t.string "caption"
    t.string "credit"
    t.string "dimensions"
    t.boolean "public"
    t.string "average_color"
  end

  create_table "plugin_schema_info", id: false, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci" do |t|
    t.string "plugin_name"
    t.integer "version"
  end

  create_table "polls", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci" do |t|
    t.string "type"
  end

  create_table "possibles", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci" do |t|
    t.string "name"
    t.text "action", limit: 16777215
    t.integer "poll_id"
    t.text "description", limit: 16777215
    t.text "description_html", limit: 16777215
    t.integer "position"
    t.index ["poll_id"], name: "index_possibles_poll_id"
  end

  create_table "posts", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci" do |t|
    t.integer "user_id"
    t.integer "discussion_id"
    t.text "body", limit: 16777215
    t.text "body_html", limit: 16777215
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
    t.string "type"
    t.integer "page_terms_id"
    t.integer "stars_count", default: 0
    t.index ["discussion_id", "created_at"], name: "index_posts_on_discussion_id"
    t.index ["user_id"], name: "index_posts_on_user_id"
  end

  create_table "profiles", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci" do |t|
    t.integer "entity_id"
    t.string "entity_type", limit: 191
    t.boolean "stranger", default: false, null: false
    t.boolean "peer", default: false, null: false
    t.boolean "friend", default: false, null: false
    t.boolean "foe", default: false, null: false
    t.string "first_name"
    t.string "middle_name"
    t.string "last_name"
    t.string "role"
    t.string "organization"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "fof", default: false, null: false
    t.text "summary"
    t.integer "wiki_id"
    t.integer "layout_id"
    t.boolean "may_see"
    t.integer "membership_policy", default: 0
    t.boolean "may_request_contact", default: true
    t.boolean "may_pester", default: true
    t.boolean "may_burden"
    t.boolean "may_spy"
    t.string "language", limit: 5
    t.integer "discussion_id"
    t.string "place"
    t.integer "video_id"
    t.text "summary_html"
    t.integer "geo_location_id"
    t.integer "picture_id"
    t.boolean "encrypt", default: false
    t.index ["entity_id", "entity_type", "language", "stranger", "peer", "friend", "foe"], name: "profiles_index"
    t.index ["wiki_id", "entity_id"], name: "profiles_for_wikis"
  end

  create_table "ratings", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci" do |t|
    t.integer "rating", default: 0
    t.datetime "created_at", null: false
    t.string "rateable_type", limit: 15, default: "", null: false
    t.integer "rateable_id", default: 0, null: false
    t.integer "user_id", default: 0, null: false
    t.index ["rateable_type", "rateable_id"], name: "fk_ratings_rateable"
    t.index ["user_id"], name: "fk_ratings_user"
  end

  create_table "relationships", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci" do |t|
    t.integer "user_id"
    t.integer "contact_id"
    t.string "type", limit: 10
    t.integer "discussion_id"
    t.datetime "visited_at", default: "1000-01-01 00:00:00", null: false
    t.integer "unread_count", default: 0
    t.integer "total_visits", default: 0
    t.index ["contact_id", "user_id"], name: "index_contacts"
    t.index ["discussion_id"], name: "index_relationships_on_discussion_id"
  end

  create_table "requests", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci" do |t|
    t.integer "created_by_id"
    t.integer "approved_by_id"
    t.integer "recipient_id"
    t.string "recipient_type", limit: 5
    t.string "email"
    t.string "code", limit: 8
    t.integer "requestable_id"
    t.string "requestable_type", limit: 10
    t.integer "shared_discussion_id"
    t.integer "private_discussion_id"
    t.string "state", limit: 10
    t.string "type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "language"
    t.integer "site_id"
    t.index ["code"], name: "code"
    t.index ["created_at"], name: "created_at"
    t.index ["created_by_id", "state"], name: "created_by_0_2", length: { state: 2 }
    t.index ["recipient_id", "recipient_type", "state"], name: "recipient_0_2_2", length: { recipient_type: 2, state: 2 }
    t.index ["requestable_id", "requestable_type", "state"], name: "requestable_0_2_2", length: { requestable_type: 2, state: 2 }
    t.index ["updated_at"], name: "updated_at"
  end

  create_table "showings", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci" do |t|
    t.integer "asset_id"
    t.integer "gallery_id"
    t.integer "position", default: 0
    t.boolean "is_cover", default: false
    t.integer "stars"
    t.integer "comment_id_cache"
    t.integer "discussion_id"
    t.string "title"
    t.index ["asset_id", "gallery_id"], name: "ag"
    t.index ["gallery_id", "asset_id"], name: "ga"
  end

  create_table "stars", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci" do |t|
    t.integer "user_id", null: false
    t.integer "starred_id", null: false
    t.string "starred_type", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "survey_answers", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci" do |t|
    t.integer "question_id"
    t.integer "response_id"
    t.integer "asset_id"
    t.text "value"
    t.string "type"
    t.datetime "created_at"
    t.integer "external_video_id"
  end

  create_table "survey_questions", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci" do |t|
    t.string "type"
    t.text "choices"
    t.integer "survey_id"
    t.integer "position"
    t.string "label"
    t.text "details"
    t.boolean "required"
    t.datetime "created_at"
    t.datetime "expires_at"
    t.string "regex"
    t.integer "maximum"
    t.integer "minimum"
    t.boolean "private", default: false
  end

  create_table "survey_responses", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci" do |t|
    t.integer "survey_id"
    t.integer "user_id"
    t.string "name"
    t.string "email"
    t.integer "stars_count", default: 0
    t.datetime "created_at"
  end

  create_table "surveys", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci" do |t|
    t.text "description"
    t.datetime "created_at"
    t.integer "responses_count", default: 0
    t.string "settings"
  end

  create_table "taggings", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci" do |t|
    t.integer "taggable_id"
    t.integer "tag_id"
    t.string "taggable_type", limit: 191
    t.datetime "created_at"
    t.string "context", limit: 128
    t.integer "tagger_id"
    t.string "tagger_type", limit: 191
    t.index ["context"], name: "index_taggings_on_context"
    t.index ["tag_id", "taggable_id", "taggable_type", "context", "tagger_id", "tagger_type"], name: "taggings_idx", unique: true
    t.index ["tag_id"], name: "index_taggings_on_tag_id"
    t.index ["taggable_id", "taggable_type", "context"], name: "index_taggings_on_taggable_id_and_taggable_type_and_context"
    t.index ["taggable_id", "taggable_type", "tagger_id", "context"], name: "taggings_idy"
    t.index ["taggable_id"], name: "index_taggings_on_taggable_id"
    t.index ["taggable_type"], name: "index_taggings_on_taggable_type"
    t.index ["tagger_id", "tagger_type"], name: "index_taggings_on_tagger_id_and_tagger_type"
    t.index ["tagger_id"], name: "index_taggings_on_tagger_id"
  end

  create_table "tags", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci" do |t|
    t.string "name", limit: 191
    t.integer "taggings_count", default: 0
    t.index ["name"], name: "index_tags_on_name", unique: true
    t.index ["name"], name: "tags_name"
  end

  create_table "task_participations", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci" do |t|
    t.boolean "watching"
    t.boolean "waiting"
    t.boolean "assigned"
    t.integer "user_id"
    t.integer "task_id"
  end

  create_table "tasks", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci" do |t|
    t.string "name"
    t.text "description", limit: 16777215
    t.text "description_html", limit: 16777215
    t.integer "position"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "completed_at"
    t.datetime "due_at"
    t.integer "created_by_id"
    t.integer "updated_by_id"
    t.integer "points"
    t.integer "page_id"
    t.index ["page_id", "position"], name: "index_tasks_on_page_id_and_position"
  end

  create_table "thumbnails", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci" do |t|
    t.bigint "parent_id"
    t.string "parent_type", limit: 191
    t.string "content_type"
    t.string "filename"
    t.string "name"
    t.bigint "size"
    t.bigint "width"
    t.bigint "height"
    t.boolean "failure"
    t.index ["parent_id", "parent_type"], name: "parent_id_and_type"
  end

  create_table "tokens", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci" do |t|
    t.integer "user_id", default: 0, null: false
    t.string "action", default: "", null: false
    t.string "value", limit: 40, default: "", null: false
    t.datetime "created_at", null: false
  end

  create_table "translations", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci" do |t|
    t.text "text"
    t.integer "key_id"
    t.integer "language_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "custom", default: false
    t.index ["key_id"], name: "index_translations_on_key_id"
  end

  create_table "user_participations", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci" do |t|
    t.integer "page_id"
    t.integer "user_id"
    t.integer "folder_id"
    t.integer "access"
    t.datetime "viewed_at"
    t.datetime "changed_at"
    t.boolean "watch", default: false
    t.boolean "star"
    t.boolean "resolved", default: true
    t.boolean "viewed"
    t.integer "message_count", default: 0
    t.boolean "attend", default: false
    t.index ["page_id", "user_id"], name: "page_and_user", unique: true
    t.index ["user_id", "changed_at"], name: "recent_changes"
  end

  create_table "users", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci" do |t|
    t.string "login", limit: 191
    t.string "email"
    t.string "crypted_password", limit: 40
    t.string "salt", limit: 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "remember_token"
    t.datetime "remember_token_expires_at"
    t.string "display_name"
    t.string "time_zone"
    t.integer "avatar_id"
    t.datetime "last_seen_at"
    t.integer "version", default: 0
    t.binary "direct_group_id_cache"
    t.binary "all_group_id_cache"
    t.binary "friend_id_cache"
    t.binary "foe_id_cache"
    t.binary "peer_id_cache"
    t.binary "tag_id_cache"
    t.string "language", limit: 5
    t.binary "admin_for_group_id_cache"
    t.boolean "unverified", default: false
    t.string "receive_notifications"
    t.string "type"
    t.string "password_digest"
    t.index ["last_seen_at"], name: "index_users_on_last_seen_at"
    t.index ["login"], name: "index_users_on_login"
  end

  create_table "votes", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci" do |t|
    t.integer "possible_id"
    t.integer "user_id"
    t.datetime "created_at"
    t.integer "value"
    t.string "comment"
    t.string "type"
    t.integer "votable_id"
    t.string "votable_type"
    t.index ["possible_id", "user_id"], name: "index_votes_possible_and_user"
    t.index ["possible_id"], name: "index_votes_possible"
  end

  create_table "websites", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci" do |t|
    t.integer "profile_id"
    t.boolean "preferred", default: false
    t.string "site_title", default: ""
    t.string "site_url", default: ""
    t.index ["profile_id"], name: "websites_profile_id_index"
  end

  create_table "wiki_locks", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci" do |t|
    t.integer "wiki_id"
    t.text "locks"
    t.integer "lock_version", default: 0
    t.index ["wiki_id"], name: "wiki_id"
  end

  create_table "wiki_versions", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci" do |t|
    t.integer "wiki_id"
    t.integer "version"
    t.text "body", limit: 16777215
    t.text "body_html", limit: 16777215
    t.datetime "updated_at"
    t.integer "user_id"
    t.text "raw_structure"
    t.index ["wiki_id", "updated_at"], name: "index_wiki_versions_with_updated_at"
    t.index ["wiki_id"], name: "index_wiki_versions"
  end

  create_table "wikis", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci" do |t|
    t.text "body", limit: 16777215
    t.text "body_html", limit: 16777215
    t.datetime "updated_at"
    t.integer "user_id"
    t.integer "version"
    t.text "raw_structure"
    t.index ["user_id"], name: "index_wikis_user_id"
  end

end
