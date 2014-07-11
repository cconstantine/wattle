require 'spec_helper'

describe StreamEvent do
  let(:watcher) {watchers :default}
  let(:grouping) {groupings :grouping1}

  context "#create!" do
    subject {StreamEvent.create!(grouping: grouping, context: grouping)}
    its(:happened_at) {should be_present}
    its(:happened_at) {should be_within(1.second).of(Time.zone.now)}
  end
end
