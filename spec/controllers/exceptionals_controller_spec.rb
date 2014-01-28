require 'spec_helper'

describe ExceptionalsController do

  describe "GET #an_exception" do
    subject { get :an_exception, format: :json }


    it "should raise an error" do
      expect {subject}.to raise_error(ExpectedError)
    end

    it "should register a wat" do
      expect {subject}.to raise_error(ExpectedError)
      controller.should be_report_wat
    end

    context "when logged in" do
      let(:user) {watchers(:default)}
      before do
        login user
      end

      it "should pass the user hash" do
        expect {subject}.to raise_error(ExpectedError)
        controller.env["wat_report"][:user].should == user
      end
    end
  end
end
