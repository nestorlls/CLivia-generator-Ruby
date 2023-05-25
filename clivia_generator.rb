require "httparty"
require "json"
require "colorize"
require "htmlentities"
require "terminal-table"
require_relative "presenter"
require_relative "requester"

class CliviaGenerator
  include Presenter
  include Requester
  include HTTParty

  def initialize
    @trivia = load_questions
    @questions = {}
    @answers = []
    @options = []
    @score = 0
    @data = parse_scores || []
  end

  def start
    action = ""

    loop do
      puts print_welcome
      action = select_main_menu_action

      break if action == "exit"

      case action
      when "random" then random_trivia
      when "scores" then print_scores
      end
    end
  end

  def random_trivia
    count = 1

    while count <= 10
      @questions = @trivia[:results].sample
      answers = [@questions[:correct_answer]].union(@questions[:incorrect_answers])
      @answers = answers

      puts "Category: #{@questions[:category]} | Difficulty: #{@questions[:difficulty]}"
      puts parse_questions
      @options = answers.shuffle.each_with_index do |ans, index|
        puts "#{index + 1}. #{ans}"
      end
      ask_questions
      count += 1
    end
    save_data
  end

  def ask_questions
    print "> "
    input = gets.chomp.to_i
    user_ans = @options.slice(input - 1)

    if @questions[:correct_answer] == user_ans
      puts "#{user_ans} is Correct!!".green
      @score += 10
    else
      puts "#{user_ans}  is Incorrect!!".red
      puts "The correct answer was: #{@questions[:correct_answer].to_s.colorize(:green)}"
    end
  end

  def save(data)
    File.write("saved_hash.json", data.to_json)
  end

  def parse_scores
    JSON.load(File.open("saved_hash.json"), nil, symbolize_names: true, create_additions: false)
  rescue Errno::ENOENT => e
    puts JSON.parse(e.message)
  end

  def load_questions
    response = HTTParty.get("https://opentdb.com/api.php?amount=20")
    JSON.parse(response.body, symbolize_names: true)
  end

  def parse_questions
    coder = HTMLEntities.new
    coder.decode(@questions[:question])
  end

  def print_scores
    arr_name_score = parse_scores.map { |hash| [hash[:name].yellow, hash[:score]] }
    table = Terminal::Table.new
    table.title = "Top Scores"
    table.headings = ["Name", "Score"]
    table.rows = arr_name_score.sort_by { |arr| -arr[1] }
    puts table
  end

  def save_data
    print_score(@score)
    data = will_save?(@score)
    return unless data

    @data << data
    save(@data)
  end
end

trivia = CliviaGenerator.new
trivia.start
