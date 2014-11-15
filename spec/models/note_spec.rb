require 'spec_helper'

describe Note do
  let(:watcher) { watchers :default }
  let(:grouping) { groupings :grouping1 }

  describe "#create" do
    subject {Note.create!(watcher: watcher, grouping: grouping, message: "HI!")}

    its(:stream_event) {should be_present}
  end

  describe "activerecord lifecycle" do
    let(:note) { Note.new grouping: grouping, watcher: watcher, message: "HI!" }

    describe "after commit" do

      subject { note.save! }

      it "should call send_email on creation of a note" do
        stub.proxy(note).send_email
        subject

        expect(note).to have_received(:send_email)
      end
    end
  end

  describe "#send_email" do
    let(:note) { Note.new grouping: grouping, watcher: watcher, message: "HI!" }

    subject { note.send_email }

    it "should notify grouping that a new note has been created" do
      Sidekiq::Testing.inline! do

        stub.proxy(GroupingNoteNotifier).notify
        subject

        expect(GroupingNoteNotifier).to have_received(:notify).with note.grouping.id
      end
    end
  end
end
