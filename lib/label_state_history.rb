require './lib/label_state.rb'

class LabelStateHistory
  attr_accessor :history_array, :current_state_index

  def initialize (*args)
    @current_state_index = -1
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
    @current_state_index = Integer(history_array[-1].label_index) # in ruby -1 index in array means last element
  end

  def record_state(current_index)
    new_state = LabelState.new(current_index, Time.now)
    @current_state_index = current_index
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
    str_array = m[1].split(",")
    str_array.each do |label_state_json|
      label_state = LabelState.new(label_state_json)
      @history_array.push(label_state)
    end
    @current_state_index = Integer(@history_array[-1].label_index)
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
    history_regex = /(.*?)\s*<!---\s\{ 'label_state_history': \[(.*?)\] \}\s-->\s*(.*?)/m
    m = history_regex.match(some_string)
    if m.nil?
      return some_string
    else
      return m[1] + m[3]
    end
  end

  def self.get_body_with_state_history(old_body, index)
    lsh_json = self.get_embedded_label_state_history(old_body)
    if (lsh_json.nil?) #if nil, we'll need to record current state
      lsh = LabelStateHistory.new
      lsh.record_state(index)
      return old_body + lsh.embed_label_state_history
    else #if state exists, we only need to record state if it's out of date
      lsh = LabelStateHistory.new(lsh_json)
      if (lsh.current_state_index == index)
        return nil
      else
        lsh.record_state(index)
        body_without_history = LabelStateHistory.get_body_without_embedded_label_state_history(old_body)
        return body_without_history + lsh.embed_label_state_history
      end
    end
  end
end