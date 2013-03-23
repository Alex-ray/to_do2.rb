require 'csv'

class CsvParser
  attr_reader :file
  def initialize(file)
    @file = file
  end
#
  def save!(tasks)
    CSV.open(file, 'wb') do |csv|
      tasks.each do |task|
        csv.add_row([task.id,task.command,task.completed,task.tags,task.time])
      end
    end
  end

  def each
    CSV.foreach(file) do |row|
      yield(Tasks.new(row[0].to_i, row[1], row[2], row[3], row[4]))
    end
  end

end

class Input
  attr_accessor :command, :name, :index, :tag

  def initialize(command_string)
    command_array = command_string.split(' ') #if command_string =~ /.* .*/
    if command_array[0].upcase == "TAGS"
      @command = command_array.shift
      @index = command_array.shift
      @tag = command_array
    elsif command_string.upcase =~ /FILTER.*/
      command_array = command_string.split(':')
      @command = command_array[0]
      @tag = command_array[1]
    else
      @command = command_array[0]
      @name = command_array[1..command_array.size].join(' ')
    end
  end

end

class Tasks
  attr_reader :id, :command, :completed, :tags
  attr_accessor :time

  def initialize(id, command, completed, tags=' ', time)
    @id = id
    @command = command
    @completed = completed
    @tags = tags
    @time = time
  end

  def complete!
    @completed = "true"
  end

  def complete?
    @completed == "true"
  end

  def taged(tags_array)
    @tags = tags_array
  end

end

class ToDo

  def initialize(file_name)
    @file = file_name
    @tasks = []
    self.load_tasks!
  end

  def do!(string)
    to_do = Input.new(string)
    case to_do.command.upcase

    when "ADD"

      id = @tasks.size + 1
      command = to_do.name
      task = Tasks.new(id, command, "false", '', Time.now.asctime)
      @tasks << task

      puts "#{to_do.name} with index: #{id} has been added to your TODO list"

    when "COMPLETE"

      id = to_do.name.to_i
      task = find(id)
      task = task.shift
      task.complete!
      task.time = Time.now.asctime
      puts "Congrats! #{task.command} at #{task.time} is now checked off your list!"

    when "LIST"
      sorted_tasks = @tasks.sort_by { |task| task.time }.reverse!

      sorted_tasks.each do |task|
        check_box = "[ ]" 
        check_box = "[x]" if task.completed == "true"
        puts "#{task.id}. #{check_box} #{task.command} #{task.tags} #{task.time}" 
      end

    when "LIST:OUTSTANDING"
  
      sorted_tasks = @tasks.sort_by { |task| task.time }.reverse!
      sorted_tasks.each do |task|
        check_box = "[]"
        if task.completed == "false"
          puts "#{task.id}. #{check_box} #{task.command}"
        end
      end

    when "LIST:COMPLETED"
      
      sorted_tasks = @tasks.sort_by { |task| task.time }.reverse!
      sorted_tasks.each do |task|

        check_box = "[x]"
        if task.completed == "true"
          puts "#{task.id}. #{check_box} #{task.command} #{Time.now.asctime}"
        end
      end

    when "TAGS"

      id = to_do.index.to_i
      task = find(id)
      task = task.shift
      if task == nil
        puts "You need to enter and index!" 
      else
        tags = to_do.tag
        puts "Tags: (#{tags.join(', ')}) Were added to #{task.command} of index #{task.id}."
        task.taged(tags.join(" "))
      end

    when "FILTER"

      @tasks.each do |task|
        unless task.tags =~ /.* .*/ 
          check_box = "[]" 
          check_box = "[x]" if task.completed == "true"
          puts "#{task.id}. #{check_box} #{task.command} #{task.tags}" if task.tags == to_do.tag
        end

        unless task.tags == nil
          task.tags.split(" ").each do |filter|
            puts "#{task.id}. #{check_box} #{task.command} #{task.tags}" if filter == to_do.tag
          end
        end
      end

    end

  end


  def find(index)
    @tasks.select { |t| t.id == index }
  end

  def save!
    csv = CsvParser.new(@file)
    csv.save!(@tasks)
  end

  def load_tasks!
    csv = CsvParser.new(@file)
    csv.each { |task| @tasks << task }
  end

end

############### Driver Code 
to_do_list = ToDo.new('todo.csv')
if ARGV.empty?
 puts "Things that you can do"
 puts "add <todo>"
 puts "list"
 puts "complete <todo>"
 puts "list:outstanding"
 puts "list:completed"
 puts "tags: <tags?>"
 puts "filter:<filter>"
else
  to_do_list.do!(ARGV.join(' '))
  to_do_list.save!
end









