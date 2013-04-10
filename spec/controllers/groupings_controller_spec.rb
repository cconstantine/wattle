require 'spec_helper'

describe GroupingsController do
  let(:error) { capture_error {raise RuntimeError.new "test message"} }

  let(:message) {error.message}
  let(:error_class) {error.class.to_s}
  let(:backtrace) { error.backtrace }

  describe "GET #index" do
    subject { get :index, format: :json }

    it {should be_success}

    it "should include groupings" do
      subject
      assigns[:groupings].to_a.should have(Grouping.count).items
    end

  end

  describe "GET #show" do
    let(:wat) { Wat.create_from_exception!(error)}
    let(:grouping) {wat.groupings.first}

    subject {get :show, id: grouping.to_param, format: :json }
    it {should be_success}
    it "should load the grouping" do
      subject
      assigns[:grouping].should == grouping
    end

  end

end
