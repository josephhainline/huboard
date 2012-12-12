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
    json_lsh = %Q{{ 'label_state_history': [{ "40" : "2012-12-05 17:53:30 +0000" },{ "50" : "2012-12-11 15:57:43 +0000" }] }}
    subject { described_class.new(json_lsh) }

    it "has a history array with one element equal to 50" do
      subject.history_array.count.should == 2
      subject.current_state_index.should == 50
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

    let(:mock_time) { mock 'time' }

    before do
      Time.stub(:now) { mock_time }
    end

    context 'a body with existing label state history' do
      let(:old_body) do %q{<!---
{ 'label_state_history': [{ "40" : "2012-12-05 17:53:30 +0000" },{ "50" : "2012-12-11 15:57:43 +0000" }] }
-->}
      end

      context 'that needs to be updated' do
        let(:index) { 42 }

        it 'adds a new entry at the end of the history' do
          subject.should == %Q{


<!---
{ 'label_state_history': [{ "40" : "2012-12-05 17:53:30 +0000" },{ "50" : "2012-12-11 15:57:43 +0000" },{ "#{index}" : "#{mock_time}" }] }
-->
}
        end

        context 'a nasty example' do
          let(:index) { 50 }
          let(:main_body) { %Q{1. ~~The "is favorited" field does not seem to be being returned in search results server response.~~
1. ~~The "modified by" property is not contained in server response~~
1. Detail View is not updating favorite/unfavorite button when state changed in another tab.  This is true for both "My Drive" and "Search", thus if detail views are open for a particular file off both the "Search" and "My Drive" tabs, changes to a file in one tab won't be reflected in the detail view of the other tab even though that other tab's directory view is updated.  This failure to update the detail view doesn't only happen off the "Search" tab but also off of the "My Drive" tab.
1. ~~"Created on" not being populated~~} }
          let(:after_body) { %Q{
<!---
@huboard:{"order":73.0}
-->}
          }
          let(:previous_label_state_history) { %Q{<!---
{ 'label_state_history': [{ "40" : "2012-12-10 16:18:44 +0000" },{ "50" : "2012-12-11 20:13:25 +0000" },{ "40" : "2012-12-12 12:46:56 +0000" }] }
-->} }

          let(:expected_label_state_history) { %Q{

<!---
{ 'label_state_history': [{ "40" : "2012-12-10 16:18:44 +0000" },{ "50" : "2012-12-11 20:13:25 +0000" },{ "40" : "2012-12-12 12:46:56 +0000" },{ "#{index}" : "#{mock_time}" }] }
-->}}

          let(:old_body) { main_body + previous_label_state_history + after_body }

          it 'replaces the label history with an updated history' do
            subject.should == main_body + after_body + expected_label_state_history + "\n"
          end
        end

        context 'when there is a huboard value in the body' do
        end

        context 'an example with two label state histories' do
          let(:old_body) { main_body + previous_label_state_history }
          let(:main_body) { 'this is my body' }
          let(:previous_label_state_history) do %Q{
<!---
{ 'label_state_history': [{ "40" : "2012-12-05 17:53:30 +0000" }] }
-->
<!---
{ 'label_state_history': [{ "40" : "2012-12-05 17:53:30 +0000" },{ "50" : "2012-12-11 15:57:43 +0000" }] }
-->
}
          end
          let(:expected_label_state_history) do %Q{
<!---
{ 'label_state_history': [{ "40" : "2012-12-05 17:53:30 +0000" },{ "50" : "2012-12-11 15:57:43 +0000" },{ "#{index}" : "#{mock_time}" }] }
-->
}
          end

          it 'replaces all the label histories with a single updated history' do
            subject.should == main_body + "\n\n" + expected_label_state_history
          end
        end
      end

      context 'that does not need to be updated' do
        let(:index) { 50 }

        it 'returns nil' do
          subject.should be_nil
        end
      end
    end

    context 'no label state history' do
      let(:old_body) { 'this is a body with no label state history' }
      let(:index) { 42 }

      it 'should add a new label_state_history object' do
        subject.should == %Q{#{old_body}\n\n<!---
{ 'label_state_history': [{ "#{index}" : "#{mock_time}" }] }
-->
}
      end
    end
  end
end
