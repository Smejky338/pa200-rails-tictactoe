# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
require_relative '../app/models/game'

Game.create!(name: 'game1')
Game.create!(name: 'game2_switched_OX', player1: 'O', player2: 'X')
