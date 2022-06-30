class CreateGames < ActiveRecord::Migration[7.0]
  def change
    create_table :games do |table|
      table.string  :name, null: false, index: true
      table.string  :state, default: 'waiting_for_player1'
      table.string  :player1, null: false, default: 'X'
      table.string  :player2, null: false, default: 'O'
      table.integer :turn, default: 0
      table.string  :board, array: true
      table.integer :board_size, default: 15
      table.integer :winning_sequence, null: false, default: 5
      table.timestamps
    end
  end
end
