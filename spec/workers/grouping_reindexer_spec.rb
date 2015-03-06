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

  describe ".debounce_enqueue" do
    before do
      allow(GroupingReindexer).to receive(:perform_async)
      allow(GroupingReindexer).to receive(:perform_in)
    end

    context "being called in quick succession" do
      subject do
        threads = Set.new
        10.times do |i|
          threads << Thread.new do
            GroupingReindexer.debounce_enqueue(grouping.id)
          end
        end
        threads.each do |thread|
          thread.join
        end
      end

      it "should enqueue the first one" do
        subject
        expect(GroupingReindexer).to have_received(:perform_async).with(grouping.id)
      end

      it "should delay the 2nd" do

        subject
        expect(GroupingReindexer).to have_received(:perform_in).with(anything, anything)
      end
    end
  end
end
