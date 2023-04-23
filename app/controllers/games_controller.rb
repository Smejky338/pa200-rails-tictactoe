class GamesController < ApplicationController
  before_action :set_game, only: %i[show destroy turn]

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
    @game = Game.new(params.require(:game).permit(:name, :player1, :player2))
    if @game.save
      render json: @game
    else
      render json: @game.errors, status: :unprocessable_entity
    end
  end

  # POST /games/1/turn
  # play a turn. Return 422 if unsuccessful.
  def turn
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
    @game = Game.find({ _id: params[:id] })
  end
end
