require 'spec_helper'

describe GroupingReindexer do
  let(:grouping) {groupings(:grouping1)}

  describe "#perform" do
    let(:grouping_reindexer) { GroupingReindexer.new }

    subject { grouping_reindexer.perform(grouping.id) }

    it "should reindex" do
      call_count = 0
      allow_any_instance_of(Grouping).to receive(:reindex) {call_count += 1}
      subject
      expect(call_count).to eq 1
    end
  end

  it_behaves_like "the debounce enqueue method"
end
