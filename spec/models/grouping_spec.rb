require 'spec_helper'

describe Grouping do

  let(:error) { capture_error {raise RuntimeError.new "test message"} }

  let(:message) {error.message}
  let(:error_class) {error.class.to_s}
  let(:backtrace) { error.backtrace }

  let(:wat) {wat.new_from_exception(error) }

  describe "#get_or_create_from_wat!" do
    subject {Grouping.create_from_wat!}
    it "creates" do
      expect {subject}
    end
  end
end
