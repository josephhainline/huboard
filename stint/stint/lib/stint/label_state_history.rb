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

  def record_state_if_changed(current_index)
    if (@history_array.size > 0)
      last_recorded_index = @history_array.last.label_index
      if (current_index != last_recorded_index)
        record_state(current_index)
      end
    else
      record_state(current_index)
    end
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
    str_array = m[1].split(",")
    str_array.each do |label_state_json|
      label_state = LabelState.new(label_state_json)
      @history_array.push(label_state)
    end
  end

  def embed_label_state_history
    return "\r\n<!---\r\n#{self.to_json}\r\n-->\r\n"
  end

  def self.get_embedded_label_state_history(some_string)
    history_regex = /({ 'label_state_history': \[.*\] })/m
    m = history_regex.match(some_string)
    return m[1] unless m.nil?
  end

  def self.get_body_without_embedded_label_state_history(some_string)
    history_regex = /(.*)\r\n<!---\r\n\{ 'label_state_history': \[(.*?)\] \}\r\n-->\r\n(.*)/m
    m = history_regex.match(some_string)
    if m.nil?
      return some_string
    else
      return m[1] + m[3]
    end
  end

end