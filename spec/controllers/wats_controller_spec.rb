require 'spec_helper'

describe WatsController do
  let!(:wat) do
    Wat.create_from_exception!(capture_error {raise RuntimeError.enw 'hi'})
  end

  describe "GET #index" do
    subject { get :index, format: :json }
    it {should be_success}


    it "should get all wats" do
      subject
      assigns[:wats].should have(Wat.count).items
    end
  end

  describe "GET #show" do
    subject { get :show, id:  wat.to_param, format: :json}

    it {should be_success}
    it "should give the wat" do
      subject
      assigns[:wat].should == wat
    end
  end

  describe "POST #create" do
    subject {post :create, format: :json , wat: {message: "hi", error_class: "ErrFoo", backtrace: [:a, :b, :c]}}
    it {should be_success}
  end
end
