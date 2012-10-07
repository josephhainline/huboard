require '/Users/josephhainline/coding/huboard/stint/stint/lib/stint/label_state.rb'

class LabelStateHistory
  attr_accessor :history_array

  def initialize (*args)
    if (args.size == 0)
      init_zero
    elsif (args.size == 1)
      from_json(args[0])
    elsif (args.size > 1)
      init_with_history_array(args)
    end
  end

  def init_zero
    @history_array = Array.new
  end

  def init_with_history_array(history_array)
    @history_array = history_array
  end

  def record_state(current_index)
    new_state = LabelState.new(current_index, Time.now)
    @history_array.push new_state
  end

  def to_json
    json = "{ 'label_state_history': ["
    @history_array.each do |h|
      json += "#{h.to_json},"
    end
    json = json[0..-2] #strip off that last comma
    json += "] }"
    return json
  end

  def from_json(json_string)
    @history_array = Array.new
    regex_history = /{ 'label_state_history': \[(.*)\] }/
    m = regex_history.match(json_string)
    puts "full match was: ", m[0]
    str_array = m[1].split(",")
    str_array.each do |label_state_json|
      puts "single entry was: ", label_state_json
      label_state = LabelState.new(label_state_json)
      @history_array.push(label_state)
    end
  end

  def self.get_embedded_label_state_history(some_string)
    regex_history = /({ 'label_state_history': \[.*\] })/
    m = regex_history.match(some_string)
    return m[1] unless m.nil?
  end

end