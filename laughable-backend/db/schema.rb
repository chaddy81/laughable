# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20160212165845) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "api_keys", force: :cascade do |t|
    t.string   "access_token"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.integer  "user_id"
  end

  create_table "changes", force: :cascade do |t|
    t.json    "values"
    t.text    "data_type"
    t.integer "data_id"
  end

  create_table "cmscontents", force: :cascade do |t|
    t.json "entry"
  end

  create_table "comedian_subscriptions", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "comedian_id"
    t.datetime "subscription_date"
    t.boolean  "active"
  end

  create_table "comedians", force: :cascade do |t|
    t.string   "last_name"
    t.text     "biography"
    t.text     "website"
    t.string   "twitter_name"
    t.string   "facebook_name"
    t.string   "instagram_name"
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
    t.string   "profile_picture"
    t.integer  "user_id"
    t.integer  "podcaster_id"
    t.boolean  "active",          default: true
    t.text     "banner_url"
    t.string   "first_name"
    t.string   "middle_name"
    t.boolean  "staging_only",    default: false
  end

  create_table "events", force: :cascade do |t|
    t.json "payload"
  end

  create_table "mixpanel_events", force: :cascade do |t|
    t.string "distinct_id"
    t.string "event"
    t.json   "payload"
  end

  create_table "podcast_episode_requests", force: :cascade do |t|
    t.integer  "podcast_episode_id"
    t.integer  "user_id"
    t.datetime "requested"
  end

  create_table "podcast_subscriptions", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "podcast_id"
    t.datetime "subscription_date"
    t.boolean  "active"
  end

  create_table "podcastepisodes", force: :cascade do |t|
    t.string  "title"
    t.integer "comedian_ids",      default: [],    array: true
    t.text    "stream_url"
    t.text    "description"
    t.integer "duration"
    t.boolean "explicit"
    t.integer "podcast_id"
    t.text    "image_url"
    t.text    "website"
    t.text    "external_keywords", default: [],    array: true
    t.integer "publish_date"
    t.text    "external_id"
    t.boolean "staging_only",      default: false
  end

  create_table "podcasters", force: :cascade do |t|
    t.string  "artist"
    t.text    "biography"
    t.text    "website"
    t.integer "comedian_id"
    t.text    "image_url"
  end

  create_table "podcasts", force: :cascade do |t|
    t.string  "title"
    t.text    "summary"
    t.text    "image_url"
    t.text    "rss_url"
    t.integer "comedian_ids", default: [],    array: true
    t.boolean "staging_only", default: false
  end

  create_table "shortened_urls", force: :cascade do |t|
    t.integer  "owner_id"
    t.string   "owner_type", limit: 20
    t.text     "url",                               null: false
    t.string   "unique_key", limit: 10,             null: false
    t.integer  "use_count",             default: 0, null: false
    t.datetime "expires_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "shortened_urls", ["owner_id", "owner_type"], name: "index_shortened_urls_on_owner_id_and_owner_type", using: :btree
  add_index "shortened_urls", ["unique_key"], name: "index_shortened_urls_on_unique_key", unique: true, using: :btree
  add_index "shortened_urls", ["url"], name: "index_shortened_urls_on_url", using: :btree

  create_table "track_requests", force: :cascade do |t|
    t.integer  "track_id"
    t.integer  "user_id"
    t.datetime "requested"
  end

  create_table "tracks", force: :cascade do |t|
    t.string   "title"
    t.string   "author"
    t.text     "description"
    t.integer  "duration"
    t.string   "track_type"
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
    t.integer  "comedians_id"
    t.string   "high_stream_url"
    t.integer  "comedian_id"
    t.string   "medium_stream_url"
    t.string   "low_stream_url"
    t.boolean  "staging_only",      default: false
  end

  add_index "tracks", ["comedians_id"], name: "index_tracks_on_comedians_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "username"
    t.string   "first_name"
    t.string   "middle_name"
    t.string   "last_name"
    t.string   "email"
    t.boolean  "admin",           default: false
    t.boolean  "fake_user",       default: false
    t.string   "phone_number"
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
    t.string   "password_digest"
    t.boolean  "beta_tester",     default: false
  end

end
