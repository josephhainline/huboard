require_relative '../lib/label_state_history'

describe LabelStateHistory do
  context 'a default LabelStateHistory' do
    subject { described_class.new }

    it "has an empty history array and no current_state" do
      subject.history_array.should == []
      subject.current_state_index.should == -1
    end
  end

  describe 'serializing input to JSON' do
    subject { described_class }
  end
  describe 'de-serializing input from JSON'
end