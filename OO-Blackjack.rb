require "pry"
class Deck
	attr_accessor :deck
	SUIT = ["Diamond", "Heart", "Club", "Spade"]
	VALUE = ["2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q" , "K", "A"]
	def initialize(n)
		@deck = []
		n.times do
			SUIT.each do |suit|
				VALUE.each do |value|
					@deck << [suit,value]
				end
			end
		end
	end

	def shuffle!
		deck.shuffle!
	end

	def deal(player)
		puts "Dealer dealt a card to #{player.name}..."
		player.hand.push(deck.pop)
	end
end

class Player
	attr_accessor :hand, :value
	attr_reader :name

	def initialize(n)
		@hand = []
		@name = n
		@value = 0
		@card_values = []
	end

	def compute(deck)
		@card_values = @hand.map {|item| item[1]}
		self.value = 0
		hand.each do |card|
			if card[1] == "A"
				self.value += 11
			elsif card[1].to_i == 0
				self.value += 10
			elsif card[1].to_i <= 10  
				self.value += card[1].to_i
			end
		end
		@card_values.select{|value| value==("A")}.count.times do  
			self.value -= 10 if self.value > 21
		end

		if check_if_blackjack
			puts "#{name}'s value is #{value} now."
			puts "Blackjack! #{name} won!"
			exit
		end
	end

	def check_if_blackjack
			@card_values.size == 2 && @card_values.include?("A") && @card_values.any?{|n| n =="10" || n =="J" || n =="Q" || n =="K"}  
	end

	def declare_value
		puts "#{name}'s value is #{value} now."
	end
end

class Human < Player
	def show_card
		puts "You got #{hand[0][0]} #{hand[0][1]} and #{hand[1][0]} #{hand[1][1]}."
	end

	def hit_or_stay(deck)
		begin
			puts "Do you want to hit or stay? (H/S)"
			answer = gets.chomp.upcase
				if answer == "H"	
					deck.deal(self)
					puts "You got #{hand.last[0]} #{hand.last[1]}"
					self.compute(deck)
					self.declare_value
				elsif answer == "S"
					puts "#{name} chose to stay."		
				end
		end until answer == "S" || self.value > 21 || self.value == 21
	end
end

class Dealer < Player
	def show_card
		puts "Dealer got #{hand[0][0]} #{hand[0][1]} and #{hand[1][0]} #{hand[1][1]}"
	end

	def hit_or_stay(deck,player)
		begin
			if self.value < 17
				deck.deal(self)
				puts "Dealer got #{hand.last[0]} #{hand.last[1]}"
				self.compute(deck)

			elsif self.value >= 17 && player.value > self.value
				deck.deal(self)
				puts "Dealer got #{hand.last[0]} #{hand.last[1]}"
				self.compute(deck)
			else
				puts "Dealer chose to stay."
			end
		end until self.value >17 || self.value == 21
		self.declare_value
	end
end

class Game
	def initialize
		@player = Human.new("Benson")
		@dealer = Dealer.new("X486")
		@deck = Deck.new(3)
	end

	def play
		@deck.deck.shuffle!

		@deck.deal(@player)
		@deck.deal(@dealer)
		@deck.deal(@player)
		@deck.deal(@dealer)

		@dealer.show_card
		@player.show_card

		@player.compute(@deck)
		@player.declare_value
		@player.hit_or_stay(@deck)
		check_if_busted(@player,@dealer)

		@dealer.compute(@deck)
		@dealer.hit_or_stay(@deck,@player)
		check_if_busted(@dealer,@player)
		check_winner
	end

	def check_if_busted(player,another_player)
		if player.value > 21
			puts "#{player.name} busted! #{another_player.name} won!"
			exit
		end
	end

	def check_winner
		if @player.value == @dealer.value
			puts "It's a tie!"
		elsif @player.value > @dealer.value
			puts "#{@player.name} won!"
		else
			puts "#{@dealer.name} won!"
		end
	end
end

Game.new.play