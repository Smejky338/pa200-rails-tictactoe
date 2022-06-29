require_relative '../models/game'

class GamesController < ApplicationController
  PLAYER_MARKS = %w[X O]

  # play a turn. Return 422 if unsuccessful.
  def turn
    puts "turn params=#{params}"
  end

  # get list of all games with details.
  def all
    puts "all params=#{params}"
    # puts "Game.all=#{Game.all.to_json}"
    Game.all.to_json
  end

  # get a signle game based on its ID.
  def get
    puts "get params=#{params}"
    Game.find_by('id': params.id).to_json
  end

  # create a new game, return its instance.
  def create # params game['name'],game['player1'], game['player2']
    puts "create params=#{params}"
    check_create_params(params)
    game, errors = Game.create(params[game['name']], params[game['player1']], params[game['player2']])
    if errors.empty?
      status 422
      errors
    else
      game.to_json
    end
  end

  # delete a game based on it ID.
  def delete
    puts "delete params=#{params}"
    errors.add(:id, 'must exist') unless params['id'].present?
  end

  def check_create_params(params)
    errors.add(:name, 'must exist') unless params[game['name']].present?
    errors.add(:player1, 'must exist') unless params[game['player1']].present?
    errors.add(:player2, 'must exist') unless params[game['player2']].present?
    errors.add(:player1, 'must be either X or O') unless PLAYER_MARKS.include?(params[game['player1']])
    errors.add(:player2, 'must be either X or O') unless PLAYER_MARKS.include?(params[game['player2']])
  end
end
