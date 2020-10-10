require_relative 'colors'

words = File.read("5desk.txt")

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

filtered_words = filter_words(words)
$secret_word = generate_secret_word(filtered_words)
$number_of_guesses = 8
$matched_letters = "_" * $secret_word.length
$matched = false
$incorrect_guess_count = 0
$misses = ""

def load_game
    clear()
    print "----------------Welcome to Hangman----------------\n\n".send(:yellow).send(:bold)
    puts "Guess the secret word by suggesting a letter within #{$number_of_guesses} number of guesses."
    play()
end

def play
    puts "Enter a single character [a-z/A-Z]:"
    input = gets.chomp.downcase

    if is_input_valid?(input)
        clear()
        check_for_matches($secret_word, input)
        display(input, $matched_letters, $misses, $incorrect_guess_count)

        if is_win?()
            print "                Congratulations!!!                \n".send(:green).send(:bold)
            print "            You Guessed The Secret Word           \n\n"
        elsif is_game_over?()
            print "                   Game Over!!!                   \n\n".send(:yellow).send(:bold)
            print "The secret word is: " + "#{$secret_word} \n\n"    .upcase.send(:bold).send(:green)
        else
            play()
        end
    else
        print "\n------------------Invalid Input-------------------\n".send(:red).send(:bold)
        play()
    end
end

#Display results
def display(guess, matched_letters, misses, incorrect_guess_count)
    #puts "Secret word: #{$secret_word} "
    puts "Length of word: #{$secret_word.length} "
    print "\n--------------------------------------------------\n\n".send(:yellow)
    puts "          Word   :".send(:brown).send(:bold) + " #{matched_letters} " .upcase.send(:green).send(:bold)
    print "\n"
    puts "          Guess  :".send(:brown).send(:bold)  + " #{guess} "          .upcase.send(:yellow).send(:bold) 
    puts "          Misses :".send(:brown).send(:bold)  + " #{misses} "         .upcase.send(:red).send(:bold)
    print "\n"
    print "          Incorrect guesses:".send(:brown).send(:bold)  + " #{incorrect_guess_count} \n\n" .send(:red).send(:bold)
    print "--------------------------------------------------\n\n".send(:yellow)
end

#Check for any matches in the secret word from the guessed letter
def check_for_matches(secret_word, guess)
    $matched = false
    secret_word_array = secret_word.split("")

    secret_word_array.each_with_index do |char, idx|
        if char == guess || char == guess.upcase
            $matched_letters.insert(idx, char).slice!(idx+1)
            $matched = true
        end
    end

    if !$matched
        $incorrect_guess_count += 1
        $misses += ", " unless $misses == ""
        $misses += guess
    end
end

#Check for a win
def is_win?
    $matched_letters == $secret_word ? true : false
end

#Check if player has reached the number of guesses
def is_game_over?
    $incorrect_guess_count == $number_of_guesses ? true : false
end

#Check if user input meets our requirements
def is_input_valid?(input)
    if input.length == 1
        (input.ord >= 97 && input.ord <=122) ? true : false
    end
end

#clear screen
def clear
    print "\e[2J\e[f"
end

load_game()