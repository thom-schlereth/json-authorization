# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2016_01_25_083537) do

  create_table "articles", force: :cascade do |t|
    t.string "external_id", null: false
    t.integer "author_id"
    t.string "blank_value"
    t.index ["author_id"], name: "index_articles_on_author_id"
  end

  create_table "comments", force: :cascade do |t|
    t.string "article_id"
    t.integer "author_id"
    t.integer "reviewing_user_id"
    t.index ["author_id"], name: "index_comments_on_author_id"
    t.index ["reviewing_user_id"], name: "index_comments_on_reviewing_user_id"
  end

  create_table "tags", force: :cascade do |t|
    t.string "taggable_type"
    t.integer "taggable_id"
    t.index ["taggable_type", "taggable_id"], name: "index_tags_on_taggable_type_and_taggable_id"
  end

  create_table "users", force: :cascade do |t|
  end

end
