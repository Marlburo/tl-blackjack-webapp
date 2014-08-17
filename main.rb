require 'rubygems'
require 'sinatra'


set :sessions, true

helpers do
	def calculate_total(cards)
		arr = cards.map {|element| element[1]}
		total = 0
			arr.each do |a|
				if a == "A"
					total += 11
				else
					total += a.to_i == 0 ? 10 : a.to_i
				end
			end
		arr.select{|element| element == "A"}.count.times do
		break if total <= 21
		total -=10
	end
	total
end 


	def card_image(card)
		suit = case card[0]
			when 'H' then 'hearts'
			when 'D' then 'diamonds'
			when 'C' then 'clubs'
			when 'S' then 'spades'
		end

		value = card[1]
		if['J', 'Q', 'K', 'A'].include?(value)
			value = case card[1]
				when 'J' then 'jack'
				when 'Q' then 'queen'
				when 'K' then 'king'
				when 'A' then 'ace'
			end
		end
		"<img src='/images/cards/#{suit}_#{value}.jpg' class='card_image'>"
	end

  def winner!(msg)
    @play_again = true
    @show_hit_or_stay_buttons = false
    @success = "<strong>#{session[:player_name]} wins!</strong> #{msg}"
  end

  def loser!(msg)
    @play_again = true
    @show_hit_or_stay_buttons = false
    @error = "<strong>#{session[:player_name]} loses.</strong> #{msg}"
  end

  def tie!(msg)
    @play_again = true
    @show_hit_or_stay_buttons = false
    @success = "<strong>It's a tie!</strong> #{msg}"
  end

end

before do
  @show_hit_or_stay_buttons = true
end


get '/' do
	if session[:player_name]
		redirect '/new_player'
	else
		redirect '/game'
	end
end

get '/new_player' do
	erb :new_player
end

post '/new_player' do
  	session[:player_name] = params[:player_name]
  	redirect '/game'
end

get '/game' do
  # create a deck and put it in session
  suits = ['H', 'D', 'C', 'S']
  values = ['2', '3', '4', '5', '6', '7', '8', '9', '10', 'J', 'Q', 'K', 'A']
  session[:deck] = suits.product(values).shuffle! # [ ['H', '9'], ['C', 'K'] ... ]

  # deal cards
  session[:aces_available] = 0
  session[:dealer_cards] = []
  session[:player_cards] = []
  session[:dealer_cards] << session[:deck].pop
  session[:player_cards] << session[:deck].pop
  session[:dealer_cards] << session[:deck].pop
  session[:player_cards] << session[:deck].pop

  erb :game
end

get '/game/main' do
	erb :game
end

post '/game/player/hit' do
	session[:player_cards] << session[:deck].pop
	
	player_total = calculate_total(session[:player_cards])
	if player_total == 21
		winner!("Congratulations you win")
	elsif player_total > 21
		loser!("sorry you lost")
	end
	erb :game
end

post '/game/player/stay' do

	redirect '/game/dealer'
end

get '/game/dealer' do
	#session[:dealer_cards]<<session[:deck].pop
	  @show_hit_or_stay_buttons = false

  # decision tree
  dealer_total = calculate_total(session[:dealer_cards])

  if dealer_total == 21
    @error = "Sorry, dealer hit blackjack."
  elsif dealer_total > 21
    @success = "Congratulations, dealer busted. You win."
  elsif dealer_total >= 17 #17, 18, 19, 20
    # dealer stays
    redirect '/game/compare'
  else
    # dealer hits
    @show_dealer_hit_button = true
  end
	erb :game
end

post '/game/dealer/hit' do
  session[:dealer_cards] << session[:deck].pop
  redirect '/game/dealer'
end

get '/game/compare' do

  player_total = calculate_total(session[:player_cards])
  dealer_total = calculate_total(session[:dealer_cards])
	
  if player_total < dealer_total
    loser!("#{session[:player_name]} stayed at #{player_total}, and the dealer stayed at #{dealer_total}.")
  elsif player_total > dealer_total
    winner!("#{session[:player_name]} stayed at #{player_total}, and the dealer stayed at #{dealer_total}.")
  else
    tie!("Both #{session[:player_name]} and the dealer stayed at #{player_total}.")
  end
	erb :game
end

get '/game_over' do
  erb :game_over
end
