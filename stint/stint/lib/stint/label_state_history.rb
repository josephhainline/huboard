#require "label_state"

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
    regex_history = /\{ 'label_state_history': \[(.*)\] \}"/
    m = regex_history.match(json_string)
    if m.nil?
      puts "m is nil"
    else
      puts "m is set:" + m
    end

    @history_array = m unless m.nil?
  end
end