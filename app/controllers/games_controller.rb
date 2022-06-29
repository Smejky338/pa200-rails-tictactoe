class GamesController < ApplicationController
  before_action :set_game, only: %i[ show update destroy ]

  PLAYER_MARKS = %w[X O]

  # GET /games
  def index
    @games = Game.all

    render json: @games
  end

  # GET /games/1
  def show
    render json: @game
  end

  # POST /games
  def create
    if params['game']['player1'].nil? || params['game']['player2'].nil?
      @game = Game.new(name: params['game']['name'])
    else
      @game = Game.new(name: params['game']['name'],
                       player1: params['game']['player1'], player2: params['game']['player2'])
    end

    if @game.save
      render json: @game # , status: :created, location: @game
    else
      render json: @game.errors, status: :unprocessable_entity
    end
  end

  # POST /games/1/turn
  # play a turn. Return 422 if unsuccessful.
  def turn
    @game = Game.find_by(id: params['id'])
    if @game
      if @game.make_turn(params)
        render json: @game
      else
        puts "Unprocessable entry, errors: #{@game.errors}"
        render json: @game.errors, status: :unprocessable_entity
      end
    else
      render json: "Game with id #{params['id']} could not be found.", status: :not_found
    end
  end

  # DELETE /games/1
  def destroy
    @game.destroy
  end

  private

    # Use callbacks to share common setup or constraints between actions.
    def set_game
      @game = Game.find(params[:id])
    end
end