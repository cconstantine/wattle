require 'spec_helper'

describe Note do
  let(:watcher) {watchers :default}
  let(:grouping) {groupings :grouping1}
  let!(:note) { Note.create!(watcher: watcher, grouping: grouping, message: "HI!") }

  describe "#create" do
    subject { note }

    it { expect(subject.stream_event).to be_present }
  end

  describe "#destroy" do
    subject { note.destroy }
    it "should delete the note" do
      expect { subject }.to change(Note, :count).by -1
    end

    it "should destroy the stream_event" do
      expect { subject }.to change(StreamEvent, :count).by -1
    end
  end
end
