require 'yaml'

def get_random_word
  word_pool = File.readlines('lib/hangman_words.txt')
  word_pool[rand(0..word_pool.length)].chomp
end

class Game
  attr_accessor :word, :guesses, :guessed
  def initialize
    @guesses = 10
    @word = get_random_word
    @guessed = Array.new

    #mainloop
  end

  #gets a legitimate guess from the user
  def process_guess letter
      #puts "Enter your guess: "
      #if letter == 'save'
      #  save_game
      #elsif letter == 'load'
      #  load_game
      #  return false#signal this game is dead
      #elsif letter.length != 1 || !(letter =~ /[a-z]/)
      #  return "Please enter a single letter."
      #elsif @guessed.include? letter
      #  return "Please a letter you have not already guessed."
      #assume valid input
    if letter.length == 1 && letter =~ /[a-z]/
      @guessed.push letter unless @guessed.include? letter
      @guesses -= 1 unless @word.include? letter
    end
  end

  def show_word
    chars = @word.split('')
    to_show = String.new

    chars.each do |char|
      to_show << (@guessed.include?(char) ? char : '_')
    end
    "Current word: #{to_show}"
  end

  def word_guessed?
    chars = @word.split('')
    chars.each do |char|
      return false unless @guessed.include? char
    end
    true
  end

  def save_game
    unless File.exist?('lib/saves.yaml')
      #create file with empty array in yaml
      File.open('lib/saves.yaml', 'w') do |saves_file|
        saves_file.puts YAML::dump(Array.new)
      end
    end

    saves_array = Array.new

    File.open('lib/saves.yaml', 'r') do |saves_file|
      saves_array = YAML::load(saves_file)
    end

    saves_array.push(self)

    File.open('lib/saves.yaml', 'w') do |saves_file|
      saves_file.puts YAML::dump(saves_array)
    end

    #puts("Game saved.")
    return true
  end

  def prepare_for_display
    display = "#{@guesses} guesses remaining for: #{show_word[14..show_word.length]}. These letters have been guessed: "
    @guessed.each {|letter| display += "#{letter}, "}
    display.chomp(', ')
  end

  def load_game
    saves_file = File.read('lib/saves.yaml')
    saves_array = YAML::load(saves_file)
    saves_array.each_with_index do |save, i|
      puts "#{i+1}: #{save.prepare_for_display}"
    end
    load_index = -1
    until (1..saves_array.length).include? load_index
      puts "Enter which game you want to load."
      load_index = gets.chomp.to_i
    end
    load_index -= 1
    saves_array[load_index].mainloop
    return false#signal this game is dead
  end

  def mainloop
    while @guesses > 0
      puts "You have #{@guesses} guesses remaining. Type 'save' to save the game or 'load' to load one."
      return 0 if get_guess == false
      puts show_word
      if word_guessed?
        puts "You guessed it! The word is indeed #{@word}."
        return true
      end
    end
    puts "You ran out of guesses with figuring out the word. It was #{@word}."
    false
  end

end
