require 'spec_helper'

describe Note do
  let(:watcher) {watchers :default}
  let(:grouping) {groupings :grouping1}

  describe "#create" do
    subject {Note.create!(watcher: watcher, grouping: grouping, message: "HI!")}

    its(:stream_event) {should be_present}
  end
end
