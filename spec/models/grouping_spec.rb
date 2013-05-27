require 'spec_helper'

describe Grouping do

  let(:error) { capture_error {raise RuntimeError.new "test message"} }

  let(:message) {error.message}
  let(:error_class) {error.class.to_s}
  let(:backtrace) { error.backtrace }

  let(:wat) {Wat.new_from_exception(error) }

  describe "#get_or_create_from_wat!" do
    subject {Grouping.get_or_create_from_wat!(wat)}
    it "creates" do
      expect {subject}.to change {Grouping.count}.by 1
    end
  end

  describe "#open?" do
    subject {grouping}

    context "with an active wat" do
      let(:grouping) {groupings(:grouping1)}
      it {should be_open}
    end
    context "with an acknowledged wat" do
      let(:grouping) {groupings(:acknowledged)}
      it {should be_open}
    end
    context "with a resolved wat" do
      let(:grouping) {groupings(:resolved)}
      it {should_not be_open}
    end
  end

  describe "#wat_order" do
    subject {Grouping.wat_order}

    it "should be sorted in-order" do
     subject.to_a.should == Grouping.all.sort {|x, y| x.wats.last.id <=> y.wats.last.id}
    end

    context "#reverse" do
      subject {Grouping.wat_order.reverse}
      it "should be sorted in-order" do
        subject.to_a.should == Grouping.all.sort {|x, y| y.wats.last.id <=> x.wats.last.id}
      end
    end
  end
end
