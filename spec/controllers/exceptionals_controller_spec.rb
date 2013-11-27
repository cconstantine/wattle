require 'spec_helper'

describe ExceptionalsController do

  describe "GET #an_exception" do
    subject { get :an_exception, format: :json }


    it "should raise an error" do
      expect {subject}.to raise_error(ExpectedError)
    end

    it "should register a wat" do
      stub.proxy(WatCatcher::Report).new

      expect {subject}.to raise_error(ExpectedError)

      expect(WatCatcher::Report).to have_received(:new).with assigns[:exception], user: nil, request: request
    end

    context "when logged in" do
      let(:user) {watchers(:default)}
      before do
        login user
      end

      it "should pass the user hash" do
        stub.proxy(WatCatcher::Report).new

        expect {subject}.to raise_error(ExpectedError)

        expect(WatCatcher::Report).to have_received(:new).with assigns[:exception], user: user, request: request
      end
    end
  end
end
