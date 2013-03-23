require 'csv'

class FileParser
  attr_reader: file_name

  def self.csv(file_name)
    CsvFileParser.new(file_name)
  end

  def save!
    raise "I need a sub class I.E. What type of file are you saving?"
  end

  def each
    raise "I need to know what data I will be iterating over I.E. I need a sub class!"
  end
end

class CsvFileParser < FileParser
  def save!(tasks)
    CSV.open(file_name, 'wb') do |csv|
      tasks.each do |task|
        csv.add_row([task.id, task.status, task.name])
    end
  end

  def each
    CSV.foreach(file_name).each do |row|
      yield(Task.new(row[0].to_i, row[1].to_sym, row[2]))
    end
  end
end


class ToDoList
  attr_accessor :tasks, :file_name
  def initialize(file)
    @file_name = file
    @tasks = []
    sel.load!
  end

  def run!(to_do_command)
    to_do = Input.new(to_do_command)
    case to_do.command.upcase
    when "ADD"
      id = @tasks.size - 1
      name = to_do.input
      Task.new(id,name)
    when "COMPLETE"
      task = self.find(to_do.id)
      task.complete!
    when "LIST"
    end
  end

  def find(index)
    @tasks[index]
  end

  def save!
    CSVFileParser.save!(@tasks)
  end

  def load!
    CSVFileParser.each do |tasks|
      @tasks << tasks
    end
  end
end

class Task
  attr_accessor :id, :status, :name
  def initialize(id, name, status=:incomplete)
    @id = id
    @status = status
    @name = name
  end

  def complete?
    @status == :complete
  end 

  def complete!
    @status = :complete
  end
end

class Input(string)
  attr_reader :command, :input
  def initialize
    string_array = string.split(' ')
    @command = string_array.first
    @input =  string_array[1..string_array.length - 1]
  end
end
ToDoList.new(ARGV.join(''))

