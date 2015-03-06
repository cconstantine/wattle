require 'spec_helper'

describe StreamEvent do
  let(:watcher) {watchers :default}
  let(:grouping) {groupings :grouping1}

  context "#create!" do
    subject {StreamEvent.create!(grouping: grouping, context: grouping)}
    it {expect(subject.happened_at).to be_present}
    it {expect(subject.happened_at).to be_within(1.second).of(Time.zone.now)}
  end

  context "#send_email" do
    let(:stream_event) {StreamEvent.new(grouping: grouping, context: GroupingVersion.last)}

    subject {stream_event.save!}

    it "should call send_email" do
      allow(stream_event).to receive(:send_email) {  }
      subject
      expect(stream_event).to have_received(:send_email)
    end
  end

end
