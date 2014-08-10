require 'rubygems'
require 'sinatra'


set :sessions, true

get '/' do
	if session[:player_name]
		redirect '/game'
	else
		redirect '/new_player'
	end
end

get '/new_player' do
	erb :new_player
end




