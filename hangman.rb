require 'sinatra'
require 'sinatra/reloader' if development?
require './lib/hangman.rb'
enable :sessions
games_by_session = Hash.new(Game.new)

get '/' do
  guess = params['guess']
  new_game = params['new_game']
  session_id = session['session_id']
  if new_game != 'true'
    game = games_by_session[session_id]
  else
    game = Game.new
    games_by_session[session_id] = game
  end
  if !guess.nil?
    game.process_guess guess
  end
  out_of_guesses = game.guesses < 1
  erb :index, :locals => {:game => game,
                          :guessed_right => game.word_guessed?,
                          :out_of_guesses => out_of_guesses}
end
