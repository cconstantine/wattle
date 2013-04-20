require 'spec_helper'

describe ExceptionalsController do

  def it_raises_error(error, &block)
  end

  describe "GET #index" do
    subject { get :an_exception, format: :json }


    it "should raise an error" do
      expect {subject}.to raise_error(ExpectedError)
    end

    it "should create a wat" do
      expect { begin;subject;rescue;end }.to change(Wat, :count).by 1
    end

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
