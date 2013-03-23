require 'csv'

class ToDo
  attr_accessor :list_item
  attr_reader :command, :file

  def initialize(command, list_item) 
    @file = 'todo.csv'
    @command = command
    @list_item = list_item
    @data = CSV.read(@file)
  end

  def list
    @data.each_with_index do |list_item, index|
      if list_item.first[0..3] == "done"
        puts "#{index}. [x] #{list_item.first[5..-1]}"
      else
        puts "#{index}. [ ] #{list_item.first}"
      end
    end
  end

  def add
    @data << [list_item.join(' ')]
    puts "Appended '#{list_item.join(' ')}' to your TODO list..."
    save!
  end

  def save!
    CSV.open(@file, 'w') do |csv|
      @data.each { |todo| csv << todo }
    end
  end

  def delete
    if @data[@list_item[0].to_i][0][0..3] == "done"
      puts "Already done you overachiever, you!!!"
    else
      puts "'#{@data[@list_item[0].to_i][0]}' has been completed."
      @data[@list_item[0].to_i] = ["done #{@data[@list_item[0].to_i][0]}"]
      save!
    end
  end
end
#Driver code 
command = ARGV[0]
list_item = ARGV[1..-1]

tasks = ToDo.new(command, list_item)

case command.downcase
when "add" then tasks.add
when "list" then tasks.list
when "delete" then tasks.delete
end
