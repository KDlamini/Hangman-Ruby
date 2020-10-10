require_relative 'colors'
require 'json'

module Container
    #Create an array of words between 5 and 12 from our dictionary
    def filter_words(words)

        filtered_words = Array.new
        words_array = words.split()

        words_array.each do |word|
            if word.length >= 5 && word.length <= 12
                filtered_words.push(word)
            end
        end

        filtered_words
    end

    #Create secret word from a list of words between 5 and 12
    def generate_secret_word(filtered_words)
        size = filtered_words.size
        
        secret_word = filtered_words[rand(size)]
    end

    #Save game and exit
    def save_and_exit(secret_word, matched_letters, guess, incorrect_guess_count, misses)
        memory_hash = {
            secret_word: secret_word,
            matched_letters: matched_letters,
            guess: guess,
            incorrect_guess_count: incorrect_guess_count, 
            misses: misses
        }

        Dir.mkdir("memory") unless Dir.exists?("memory")
        filename = "memory/saved_game.txt"
      
        File.open(filename,'w') do |file|
          file.puts JSON.generate(memory_hash)
        end
    end

    #Parse saved data and continue with game
    def get_saved_game
        data = File.read("memory/saved_game.txt")
        data = JSON.parse(data)
        hangman = Game.new

        data.each do |(key, value)|
            case key
            when "secret_word"
                hangman.secret_word = value
            when "matched_letters"
                hangman.matched_letters = value
            when "guess"
                hangman.guess = value
            when "incorrect_guess_count"
                hangman.incorrect_guess_count = value
            when "misses"
                hangman.misses = value
            else
                puts "something went wrong..."
            end
        end

        hangman
    end

    #Clear saved data
    def clear_memory
        File.delete("memory/saved_game.txt")
    end

    #clear screen
    def clear
        print "\e[2J\e[f"
    end
end

class Game
    include Container
    attr_accessor :number_of_guesses, :secret_word, :matched_letters, 
                  :guess, :incorrect_guess_count, :misses
    @@words = File.read("5desk.txt")

    def initialize
        @filtered_words = self.filter_words(@@words)
        @secret_word = self.generate_secret_word(@filtered_words)
        @number_of_guesses = 8
        @matched_letters = "_" * @secret_word.length
        @matched = false
        @guess = ""
        @incorrect_guess_count = 0
        @misses = ""
    end
    def play
        resume?()
    end

    def load_game
        self.clear()
        print "----------------Welcome to Hangman----------------\n\n".send(:yellow).send(:bold)
        puts "Guess the secret word by suggesting a letter within #{@number_of_guesses} number of guesses."
        sleep 1
        display()
        player_input()
    end

    def resume?
        if (Dir.empty? "memory")
            load_game()
        else
            self.clear()
            print "\n\nDo you wish to resume game? Y/N:\n"
            input = gets.chomp.downcase

            case input
            when "y"
                sleep 1
                self.clear()
                hangman = self.get_saved_game()
                hangman.display()
                hangman.player_input()
            when "n"
                self.clear_memory()
                load_game()
            else
                resume?()
            end
        end
    end

    def player_input
        puts "Enter a single character [a-z/A-Z]:"
        input = gets.chomp.downcase

        if input.to_i == 1

            self.save_and_exit(@secret_word, @matched_letters, @guess, @incorrect_guess_count, @misses)
            print "\n\n                    Goodbye!!!                     \n\n".send(:yellow).send(:bold)

        elsif is_input_valid?(input)
            self.clear()
            @guess = input
            check_for_matches(input    )
            display()
    
            if is_win?()
                print "                Congratulations!!!                \n".send(:green).send(:bold)
                print "            You Guessed The Secret Word           \n\n"
                self.clear_memory() unless Dir.empty? "memory"
                play_again?()
            elsif is_game_over?()
                print "                   Game Over!!!                   \n\n".send(:yellow).send(:bold)
                print "The secret word is: " + "#{@secret_word} \n\n"    .upcase.send(:bold).send(:green)
                self.clear_memory() unless Dir.empty? "memory"
                play_again?()
            else
                player_input()
            end
        else
            print "\n------------------Invalid Input-------------------\n".send(:red).send(:bold)
            player_input()
        end
    end

    #Display results
    def display()
        print "\n                                                      Save and Exit: press 1\n"
        print "\nLength of word: #{@secret_word.length} \n"
        print "\n--------------------------------------------------\n\n".send(:yellow)
        puts "          Word   :".send(:brown).send(:bold) + " #{@matched_letters} " .upcase.send(:green).send(:bold)
        print "\n"
        puts "          Guess  :".send(:brown).send(:bold)  + " #{@guess} "          .upcase.send(:yellow).send(:bold) 
        puts "          Misses :".send(:brown).send(:bold)  + " #{@misses} "         .upcase.send(:red).send(:bold)
        print "\n"
        print "          Incorrect guesses:".send(:brown).send(:bold)  + " #{@incorrect_guess_count} \n\n" .send(:red).send(:bold)
        print "--------------------------------------------------\n\n".send(:yellow)
    end

    protected

    #Check for any matches in the secret word from the guessed letter
    def check_for_matches(input)
        @matched = false
        secret_word_array = @secret_word.split("")

        secret_word_array.each_with_index do |char, idx|
            if char == input || char == input.upcase
                @matched_letters.insert(idx, char).slice!(idx+1)
                @matched = true
            end
        end

        if !@matched
            @incorrect_guess_count += 1
            @misses += ", " unless @misses == ""
            @misses += input
        end
    end

    #Prompt player if they wish to play again
    def play_again?
        print "\nDo you wish to play again? Y/N:\n"
        input = gets.chomp.downcase

        case input
        when "y"
            sleep 1
            self.clear()
            hangman = Game.new
            hangman.display()
            hangman.player_input()
        when "n"
            print "\n\n                    Goodbye!!!                     \n\n".send(:yellow).send(:bold)
        else
            self.clear()
            play_again?()
        end
    end

    #Check if user input meets our requirements
    def is_input_valid?(input)
        if input.length == 1
            (input.ord >= 97 && input.ord <=122) ? true : false
        end
    end

    #Check for a win
    def is_win?
        @matched_letters == @secret_word ? true : false
    end

    #Check if player has reached the number of guesses
    def is_game_over?
        @incorrect_guess_count == @number_of_guesses ? true : false
    end
end

hangman = Game.new()
hangman.play()