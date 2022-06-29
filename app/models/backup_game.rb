#!/usr/bin/env ruby

require 'active_record'

# Represents a board of players or nil (if the field is free there is nil)
class Game < ActiveRecord::Base
  serialize :board
  before_create :prefill
  PLAYER_MARKS = %w[X O]

  validates :name, presence: true, uniqueness: true
  validates :player1, presence: true, inclusion: { in: PLAYER_MARKS }
  validates :player2, presence: true, inclusion: { in: PLAYER_MARKS }
  
  # Called when creating new game, fills in default data.
  def prefill
    self.board = Array.new(board_size) { Array.new(board_size) }
    self.current_player = %w[X O].sample
    self.state = %w[waiting_for_player1 waiting_for_player2].sample
  end

  def next_round
    switch_player
    # Frontend.render_board(board)
    # Frontend.prompt_next_command(current_player)
    # Frontend.get_game_command
  end

  # main game action that gets looped.
  """def run
    game_won = false
    until game_won
      input = next_round
      case input[0]
      when 'exit'
        #Frontend.print_game_exit
        switch_player # undo the switch
        return nil
      when 'place'
        result = place(input[1], input[2])
        case result
        when :out_of_range
          #Frontend.print_out_of_range_error(board_size)
          switch_player
        when :cell_already_taken
          #Fnext_roundrontend.print_cell_taken_error
          switch_player
        else
          game_won = result
        end
      end
    end
    #Frontend.render_board(board)
    #Frontend.print_game_won_by(current_player)
  end
  """

  def switch_player
    turn += 1
    case state
    when 'waiting_for_player1'
      self.state = 'waiting_for_player2'
    when 'waiting_for_player2'
      self.current_player = 'waiting_for_player1'
    else
      raise 'Player not set!'
    end
  end

  # Returns nil if cell already taken or do nothing if player=nil or out of board's range(bounds)
  def try_place(row, col)
    return nil if current_player.nil?

    begin
      return :cell_already_taken unless board[row][col].nil?
    rescue NoMethodError
      errors.add("Out of board range. Pick a number between 0 and #{self.board_size-1}")
    end

    board[row][col] = current_player
  end

  # Places a player's token on the board.
  def place(row, col)
    errors.add("Out of board range. Pick a number between 0 and #{self.board_size-1}") unless check_bounds(row, col)

    ret_val = try_place(row, col)
    return check_win(row, col) if PLAYER_MARKS.include?(ret_val)

    ret_val
  end

  def check_win(row, col)
    check_row_win(row, col) || check_col_win(row, col) || check_diagonal_win(row, col)
  end

  def check_row_win(row, col)
    left_right = get_row_bounds(row, col)
    count = 0
    left_right.each do |i|
      if board[row][i] == current_player
        count += 1
      else
        count = 0
      end
      return true if count >= winning_sequence
    end
    false
  end

  # Gets a range of valid neighboring columns for a given coordinate.
  # Useful for checking if there is a winning sequence of tokens on board.
  def get_row_bounds(_, col)
    col_index = col - 1
    left_bound = [col_index - winning_sequence, 0].max
    right_bound = [col_index + winning_sequence, board_size - 1].min

    left_bound..right_bound
  end

  def check_col_win(row, col)
    up_down = get_col_bounds(row, col)
    count = 0
    up_down.each do |i|
      if board[i][col] == current_player
        count += 1
      else
        count = 0
      end
      return true if count >= winning_sequence
    end
    false
  end

  def get_col_bounds(row, _)
    up_bound   = (row - (winning_sequence - 1)).negative?  ? 0 : row - (winning_sequence - 1)
    down_bound = row + (winning_sequence - 1) > board_size ? 0 : row + (winning_sequence - 1)
    up_bound..down_bound
  end

  # Bound with overload
  def get_unlimited_bounds(row, col)
    up_bound = row - (winning_sequence - 1)
    down_bound = row + (winning_sequence - 1)
    left_bound = col - (winning_sequence - 1)
    right_bound = col + (winning_sequence - 1)
    [(up_bound..down_bound).to_a, (left_bound..right_bound).to_a]
  end

  def check_win_arrays(rows, cols)
    i = 0
    sequence_count = 0
    while i < rows.length
      row = rows[i]
      col = cols[i]
      if check_bounds(row, col) && (board[row][col] == current_player)
        if (sequence_count += 1) >= winning_sequence
          return true
        end
      else
        sequence_count = 0
      end
      i += 1
    end
  end

  def check_diagonal_win(row, col)
    up_down, left_right = get_unlimited_bounds(row, col)
    # Check starting left up
    return true if check_win_arrays(up_down, left_right)

    # Check starting right up
    right_left = left_right.reverse
    return true if check_win_arrays(up_down, right_left)

    false
  end

  def check_bounds(row, col)
    bounds = 0..board_size - 1
    bounds.cover?(row) and bounds.cover?(col)
  end
end
