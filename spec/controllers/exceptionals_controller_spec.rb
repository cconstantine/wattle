require 'spec_helper'

describe ExceptionalsController, :type => :controller do
  before { allow(controller.request).to receive(:referrer).and_return('http://example.com') }

  describe "GET #an_exception" do
    subject { get :an_exception, format: :json }


    it "should raise an error" do
      expect {subject}.to raise_error(ExpectedError)
    end

    it "should register a wat" do
      expect {subject}.to raise_error(ExpectedError)
      expect(controller).to be_report_wat
    end

    context "when logged in" do
      let(:user) {watchers(:default)}
      before do
        login user
      end

      it "should pass the user hash" do
        expect {subject}.to raise_error(ExpectedError)
        expect(request.env["wat_report"][:user]).to eq user
      end
    end
  end
end
