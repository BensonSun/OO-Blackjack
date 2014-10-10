
require "pry"
class Card
	attr_accessor :suit, :face_value
	
	def initialize(s,fv)
		@suit = s
		@face_value = fv
	end

	def to_s
		"#{suit} #{face_value}"
	end
end


class Deck
	SUIT = ["Heart", "Diamond", "Spade", "Club"]
	VALUE = ["2","3","4","5","6","7","8","9","10","J","Q","K","A"]
	attr_accessor :cards

	def initialize
		@cards = []
		SUIT.each do |suit|
			VALUE.each do |value|
				@cards << Card.new(suit,value)
			end
		end 
	end

	def shuffle!
		cards.shuffle!
	end

	def deal_one
		cards.pop
	end

	def size
		cards.size
	end
end


module Hand
	def show_card
		puts "-----#{name}'s cards:-----"
		hand_cards.each do |card|
			puts "=> #{card}"
		end
		puts "Total: #{total}"
	end


	def total
	values = hand_cards.map {|item| item.face_value }
  total = 0
  values.each do |value|
    if value == "A"
      total += 11   
    else total += (value.to_i == 0 ? 10 : value.to_i)
    end 
  end

  #correct A's value
  values.select {|value| value == "A" }.count.times do
    total -= 10 if total > Blackjack::BLACKJACK_AMOUNT
  end
  total
	end

	def add_card(new_card)
	hand_cards	<< new_card
	end

	def is_busted?
		total > Blackjack::BLACKJACK_AMOUNT
	end

end


class Player
  attr_accessor :name, :hand_cards
	include Hand

	def initialize
		@name = "Player"
		@hand_cards = []
	end

	def show_flop
		show_card
	end

end

class Dealer
	attr_accessor :name, :hand_cards
	include Hand

	def initialize
		@name = "Dealer"
		@hand_cards = []
	end

	def show_flop
		puts "-----#{name}'s cards:-----"
		puts "=> The first card is hidden."
		puts "=> The second card is #{hand_cards[1]}"
	end

end

class Blackjack
	BLACKJACK_AMOUNT = 21
	DEALER_HIT_MIN = 17
	attr_accessor :player, :dealer, :deck

	def initialize
		@player = Player.new
		@dealer = Dealer.new
		@deck = Deck.new
	end

	def set_player_name
		begin
			puts "What's your name?"
			player.name = gets.chomp
		end until player.name != ""
	end

	def deal_cards
		player.add_card(deck.deal_one)
		dealer.add_card(deck.deal_one)
		player.add_card(deck.deal_one)
		dealer.add_card(deck.deal_one)
	end

	def show_flops
		player.show_flop
		dealer.show_flop
	end

	def play	
		deck.shuffle!
		set_player_name
		deal_cards
		show_flops
		player_turn
		dealer_turn
		who_wins?
	end

	def blackjack_or_busted?(player_or_dealer)
		if player_or_dealer.total > BLACKJACK_AMOUNT
			if player_or_dealer.is_a?(Player)
				puts "#{player.name} busted, dealer won!"
				play_again?
			elsif player_or_dealer.is_a?(Dealer)
				puts "Dealer busted, #{player.name} won!"
				play_again?
			end
		elsif player_or_dealer.total == BLACKJACK_AMOUNT
			if player_or_dealer.is_a?(Player)
				puts "Congratulations! #{player.name} hit Blackjack! #{player.name} won!"
				play_again?
			elsif player_or_dealer.is_a?(Dealer)
				puts "Sorry, dealer hit Blackjack. #{player.name} lost."
				play_again?
			end
		end
	end

	def player_turn
		blackjack_or_busted?(player)
		puts "-----#{player.name}'s turn.-----"
		while !player.is_busted?
			puts "Do you want to hit or stay? (H/S)"
			response = gets.chomp.upcase
				if response == "H"
					player.add_card(deck.deal_one)
					puts "#{player.name} got #{player.hand_cards.last}, for a total:#{player.total}."
				elsif response == "S"
					puts "#{player.name} chose to stay."
					break
				elsif !["H", "S"].include?(response)
					puts "Error: please enter H or S!"
				end
			blackjack_or_busted?(player)
		end
	end

	def dealer_turn
		puts "-----Dealer's turn.-----"
		loop do 
			if dealer.total < DEALER_HIT_MIN  
				puts "Dealer chose to hit"
				dealer.add_card(deck.deal_one)
				puts "Dealer got #{dealer.hand_cards.last}, for a total:#{dealer.total}."
			else
				blackjack_or_busted?(dealer)
				puts "Dealer chose to stay."
				puts "Dealer's total is #{dealer.total}."
				break
			end
		end
		blackjack_or_busted?(dealer)
	end

	def who_wins?
		if player.total > dealer.total
			puts "Congratulations! #{player.name} won!"
		elsif player.total < dealer.total
			puts "Sorry, dealer won!"
		else
			puts "It's a tie!"
		end
		play_again?
	end

	def play_again?
		puts ""
		begin
			puts "Do you want to play again? (Y/N)"
			a = gets.chomp.upcase
			if a == "Y"
				player.hand_cards = [] 
				dealer.hand_cards = [] 
				deck = Deck.new
				puts ""
				puts "-----Start a new game....-----"
				puts ""
				play
			elsif a == "N" 
				puts "Goodbye!"
				exit
			end
		end until ["Y", "N"].include?(a)
	end
end

Blackjack.new.play