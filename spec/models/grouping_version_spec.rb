require 'spec_helper'

describe GroupingVersion, versioning: true do
  let(:watcher) {watchers :default}
  let(:grouping) {groupings :grouping1}

  describe "#create" do
    subject {grouping.acknowledge! }
    it "should make a stream_event" do
      expect {subject}.to change {StreamEvent.count}.by 1
    end
  end
end
