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
    def save_and_exit(secret_word, matched_letters, guess, guesses_left, misses)
        memory_hash = {
            secret_word: secret_word,
            matched_letters: matched_letters,
            guess: guess,
            guesses_left: guesses_left, 
            misses: misses
        }

        Dir.mkdir("memory") unless Dir.exists?("memory")
        filename = "memory/saved_game.csv"
      
        File.open(filename,'w') do |file|
          file.puts JSON.generate(memory_hash)
        end
    end

    #Parse saved data and continue with game
    def get_saved_game
        data = File.read("memory/saved_game.csv")
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
            when "guesses_left"
                hangman.guesses_left = value
            when "misses"
                hangman.misses = value
            else
                puts "something went wrong..."
            end
        end

        hangman
    end

    #Check if game is saved in memory directory
    def is_game_saved?
        File.exists? "memory/saved_game.csv"
    end

    #Clear saved data
    def clear_memory
        File.delete("memory/saved_game.csv")
    end

    #clear screen
    def clear
        print "\e[2J\e[f"
    end
end