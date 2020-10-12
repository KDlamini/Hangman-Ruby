require_relative 'colors'
require_relative 'module_container'
require 'csv'
require 'json'

class Game
    include Container
    attr_accessor :number_of_guesses, :secret_word, :matched_letters, 
                  :guess, :guesses_left, :misses
    @@words = File.read("5desk.txt")

    def initialize
        @filtered_words = self.filter_words(@@words)
        @secret_word = self.generate_secret_word(@filtered_words)
        @number_of_guesses = 8
        @matched_letters = "_" * @secret_word.length
        @matched = false
        @guess = ""
        @guesses_left = @number_of_guesses
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
        prompt_player()
    end

    def resume?
        #Call method that that checks for saved game file
        if self.is_game_saved?()
            self.clear()
            print "\n\nDo you wish to resume game? Y/N:\n"
            input = gets.chomp.downcase

            case input
            when "y"
                sleep 1
                self.clear()
                hangman = self.get_saved_game()
                hangman.display()
                hangman.prompt_player()
            when "n"
                self.clear_memory()
                load_game()
            else
                resume?()
            end
        else
            load_game()
        end
    end

    #Get player guess input and validate
    def prompt_player
        puts "Enter a single character [a-z/A-Z]:"
        input = gets.chomp.downcase

        if input.to_i == 1

            self.save_and_exit(@secret_word, @matched_letters, @guess, @guesses_left, @misses)
            print "\n\n                    Goodbye!!!                     \n\n".send(:yellow).send(:bold)

        elsif is_input_valid?(input)
            self.clear()
            @guess = input
            check_for_matches(input)
            display()
    
            if is_win?()
                print "                Congratulations!!!                \n".send(:green).send(:bold)
                print "            You Guessed The Secret Word           \n\n"
                self.clear_memory() unless !self.is_game_saved?()
                play_again?()
            elsif is_game_over?()
                print "                   Game Over!!!                   \n\n".send(:yellow).send(:bold)
                print "The secret word is: " + "#{@secret_word} \n\n"    .upcase.send(:bold).send(:green)
                self.clear_memory() unless !self.is_game_saved?()
                play_again?()
            else
                prompt_player()
            end
        else
            print "\n------------------Invalid Input-------------------\n".send(:red).send(:bold)
            prompt_player()
        end
    end

    #Display results
    def display()
        print "\n                  Save and Exit: press 1\n"
        print "\nLength of word: #{@secret_word.length} \n"
        print "\n--------------------------------------------------\n\n".send(:yellow)
        puts "          Word   :".send(:brown).send(:bold) + " #{@matched_letters} " .upcase.send(:green).send(:bold)
        print "\n"
        puts "          Guess  :".send(:brown).send(:bold)  + " #{@guess} "          .upcase.send(:yellow).send(:bold) 
        puts "          Misses :".send(:brown).send(:bold)  + " #{@misses} "         .upcase.send(:red).send(:bold)
        print "\n"
        print "          Guesses left:".send(:brown).send(:bold)  + " #{@guesses_left} \n\n" .send(:red).send(:bold)
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
            @guesses_left -= 1
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
            hangman.prompt_player()
        when "n"
            print "\n\n                    Goodbye!!!                     \n\n".send(:yellow).send(:bold)
        else
            self.clear()
            play_again?()
        end
    end

    #Check if user input meets game requirements
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
        @guesses_left == 0 ? true : false
    end
end

hangman = Game.new()
hangman.play()