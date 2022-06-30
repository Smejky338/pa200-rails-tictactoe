# Game implementation
class Game < ApplicationRecord
  serialize :board
  serialize :matrix
  before_create :prefill
  PLAYER_MARKS = %w[X O]

  validates :name, presence: true, uniqueness: true
  validates :player1, presence: true, inclusion: { in: PLAYER_MARKS }
  validates :player2, presence: true, inclusion: { in: PLAYER_MARKS }

  # Called when creating new game, fills in default data.
  def prefill
    self.board_size = 15
    self.matrix = Array.new(board_size) { Array.new(board_size) }
    self.board = { 'matrix' => matrix, 'size' => board_size }
    self.state = %w[waiting_for_player1 waiting_for_player2].sample
    self.player1 = 'X'
    self.player2 = 'O'
  end

  def current_symbol
    case state
    when 'waiting_for_player1'
      player1
    when 'waiting_for_player2'
      player2
    end
  end

  def switch_player
    self.turn += 1
    case state
    when 'waiting_for_player1'
      self.state = 'waiting_for_player2'
    when 'waiting_for_player2'
      self.state = 'waiting_for_player1'
    else
      raise "Player not set or game already won! State=#{state}"
    end
  end

  # Returns nil if cell already taken or do nothing if player=nil or out of matrix's range(bounds)
  def try_place(row, col)
    return nil if state.nil?

    begin
      @errors.append('Cell already taken!') unless board['matrix'][row][col].nil?
    rescue NoMethodError
      @errors.append("Out of board range. Pick a number between 0 and #{board_size - 1}")
    end
    return unless @errors.empty?

    board['matrix'][row][col] = current_symbol
  end

  # Places a player's token on the board.
  def place(row, col)
    errors.append("Out of board range. Pick a number between 0 and #{board_size - 1}") unless check_bounds(row, col)
    ret_val = try_place(row, col)
    return check_win(row, col) if PLAYER_MARKS.include?(ret_val)

    ret_val
  end

  def validate_turn_params(params)
    @errors.append(:row, 'must be present') if params['turn']['row'].nil?
    @errors.append(:column, 'must be present') if params['turn']['column'].nil?
    @errors.append(:symbol, 'must be present') if params['turn']['symbol'].nil?
  end

  def make_turn(params)
    @errors = []
    validate_turn_params(params)
    if @errors.empty?
      request_symbol = params['turn']['symbol']
      unless current_symbol == request_symbol
        @errors.append(:symbol, 'Must be for the current player or the game is won.')
      end

      row = Integer(params['turn']['row'], exception: false)
      @errors.append(:row, 'must be a number') if row.nil?
      col = Integer(params['turn']['column'], exception: false)
      @errors.append(:column, 'must be a number') if col.nil?
      if @errors.empty?
        game_won = place(row, col)
        switch_player if @errors.empty? && !game_won
        save
      end
    else
      false
    end
  end

  def check_win(row, col)
    win = (check_row_win(row, col) || check_col_win(row, col) || check_diagonal_win(row, col))
    if win
      case state
      when 'waiting_for_player1'
        self.state = 'player1_won'
      when 'waiting_for_player2'
        self.state = 'player2_won'
      end
      save
    end
    win
  end

  def check_row_win(row, col)
    left_right = get_row_bounds(row, col)
    count = 0
    left_right.each do |i|
      if board['matrix'][row][i] == current_symbol
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
      if board['matrix'][i][col] == current_symbol
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
      if check_bounds(row, col) && (board['matrix'][row][col] == current_symbol)
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
