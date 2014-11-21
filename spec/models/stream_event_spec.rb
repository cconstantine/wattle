require 'spec_helper'

describe StreamEvent do
  let(:watcher) {watchers :default}
  let(:grouping) {groupings :grouping1}

  context "#create!" do
    subject {StreamEvent.create!(grouping: grouping, context: grouping)}
    its(:happened_at) {should be_present}
    its(:happened_at) {should be_within(1.second).of(Time.zone.now)}
  end

  context "#send_email" do
    let(:stream_event) {StreamEvent.new(grouping: grouping, context: GroupingVersion.last)}

    subject {stream_event.save!}

    it "should call send_email" do
      stub.proxy(stream_event).send_email
      subject
      expect(stream_event).to have_received(:send_email)
    end
  end

end
