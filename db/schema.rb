# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.0].define(version: 20_220_627_223_524) do
  create_table 'games', force: :cascade do |t|
    t.string 'name', null: false
    t.string 'state', default: 'waiting_for_player1'
    t.string 'board'
    t.string 'player1', default: 'X', null: false
    t.string 'player2', default: 'O', null: false
    t.integer 'board_size', default: 15
    t.integer 'winning_sequence', default: 5, null: false
    t.integer 'turn', default: 0
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.index ['name'], name: 'index_games_on_name'
  end
end
