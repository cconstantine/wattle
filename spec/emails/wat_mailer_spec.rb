require 'spec_helper'

describe WatMailer do
  let(:grouping)   { groupings(:grouping1) }

  context "Wat after_create" do
    let(:wat) { grouping.wats.first.dup }
    subject   { wat.save! }
    it "should send an email to all users" do
      stub.proxy(WatMailer).create
      subject
      expect(WatMailer).to have_received(:create).with(wat)
    end

    context "with a wat that is from an acknowledged grouping" do
      let(:grouping) {groupings(:acknowledged)}

      it "should not send an email to all users" do
        stub.proxy(WatMailer).create
        subject
        expect(WatMailer).to_not have_received(:create)
      end
    end
    context "with a wat that is from a resolved grouping" do
      let(:grouping) {groupings(:resolved)}

      it "should send an email to all users" do
        stub.proxy(WatMailer).create
        subject
        expect(WatMailer).to have_received(:create).with(wat)
      end
    end
  end

  context "create" do
    let(:wat) { grouping.wats.first }
    subject   {WatMailer.create(wat)}

    it {should deliver_to(*Watcher.pluck(:email))}

    it {should have_body_text "a test"}
  end

end