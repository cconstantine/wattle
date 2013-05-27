require 'spec_helper'

describe WatMailer do
  let(:error) { capture_error {raise RuntimeError.new "test message"} }
  let(:wat)   { Wat.new_from_exception(error)}

  context "Wat after_create" do
    subject { wat.save! }
    it "should send an email to all users" do
      WatMailer.should_receive(:create).with(wat).and_call_original
      subject
    end
  end

  context "create" do
    subject {WatMailer.create(wat)}

    it {should deliver_to(*Watcher.pluck(:email))}

    it {should have_body_text "test message"}
  end

end