require 'spec_helper'

describe WatMailer do
  let(:wat)        { grouping.wats.first.dup }
  let(:grouping)   { groupings(:grouping1) }

  context "Wat after_create" do
    subject { wat.save! }
    it "should send an email to all users" do
      WatMailer.should_receive(:create).with(wat).and_call_original
      subject
    end

    context "with a wat that is from an acknowledged grouping" do
      let(:grouping) {groupings(:acknowledged)}

      it "should send an email to all users" do
        WatMailer.should_not_receive(:create).with(wat).and_call_original
        subject
      end
    end
  end

  context "create" do
    subject {WatMailer.create(wat)}

    it {should deliver_to(*Watcher.pluck(:email))}

    it {should have_body_text "a test"}
  end

end