require_relative '../lib/label_state_history'

describe LabelStateHistory do
  context 'a default LabelStateHistory' do
    subject { described_class.new }

    it "has an empty history array and no current_state" do
      subject.history_array.should == []
      subject.current_state_index.should == -1
    end
  end

  describe 'deserializing input from JSON' do
    json_lsh = "<!--- { 'label_state_history': [{ \"40\" : \"2012-12-05 17:53:30 +0000\" }] } -->"
    subject { described_class.new(json_lsh) }

    it "has a history array with one element equal to 40" do
      subject.history_array.count.should == 1
      subject.current_state_index.should == 40
    end
  end

  describe 'serializing input to JSON' do
    let(:expected_json) do
      "{ 'label_state_history': [{ \"10\" : \"#{mock_time.to_s}\" }] }"
    end

    let(:mock_time) { mock 'time' }
    let(:current_index) { 10 }

    subject { described_class.new }

    before do
      Time.stub(:now) { mock_time }
      subject.record_state(current_index)
    end

    it "can be deserialized and reserialized" do
      subject.to_json.should == expected_json
    end
  end

  describe 'getting the body with state history' do
    subject { described_class.get_body_with_state_history(old_body, index) }

    let(:index) { 42 }
    let(:mock_time) { mock 'time' }

    before do
      Time.stub(:now) { mock_time }
    end

    context 'a body with existing label state history that needs to be updated' do
      let(:old_body) do %q{<!---
{ 'label_state_history': [{ "40" : "2012-12-05 17:53:30 +0000" },{ "50" : "2012-12-11 15:57:43 +0000" }] }
-->'}
      end

      it 'adds a new entry at the end of the history' do
        subject.should == %Q{

<!---
{ 'label_state_history': [{ "40" : "2012-12-05 17:53:30 +0000" },{ "50" : "2012-12-11 15:57:43 +0000" },{ "#{index}" : "#{mock_time}" }] }
-->
}

      end
    end

    context 'a body with existing label state history that does not need to be updated'
    context 'no label state history'
  end
end
