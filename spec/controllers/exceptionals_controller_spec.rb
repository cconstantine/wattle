require 'spec_helper'

describe ExceptionalsController do

  describe "GET #an_exception" do
    subject { get :an_exception, format: :json }


    it "should raise an error" do
      expect {subject}.to raise_error(ExpectedError)
    end

  end
end
