module Requester
  def select_main_menu_action
    gets_option(["random", "scores", "exit"])
  end

  def ask_question(question)
    # show category and difficulty from question
    # show the question
    # show each one of the options
    # grab user input
  end

  def will_save?(score)
    input = ""
    loop do
      puts "-" * 50
      puts "Do you want to save your score? (y/n)"
      input = gets.chomp

      case input
      when "y"
        puts "Type the name to assign to the score"
        print "> "
        name = gets.chomp
        user_name = name.empty? ? "Anonymous" : name
        return { name: user_name, score: score }
      when "n" then break
      end
    end
  end

  def gets_option(options)
    action = ""
    until options.include?(action)
      puts options.join(" | ")
      print "> "
      action = gets.chomp
      puts "Choose the correct option!" unless options.include?(action)
    end
    action
  end
end
