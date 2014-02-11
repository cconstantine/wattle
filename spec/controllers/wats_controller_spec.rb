require 'spec_helper'

describe WatsController do
  render_views

  let!(:wat) do
    Wat.create_from_exception!(capture_error {raise RuntimeError.enw 'hi'})
  end

  describe "GET #index" do
    subject { get :index, per_page: 100}
    context 'when logged in' do
      before do
        login watchers(:default)
      end

      it {should be_success}


      it "should get all wats" do
        subject
        assigns[:wats].should have(Wat.count).items
      end
    end
  end

  describe "GET #show" do
    subject { get :show, id: wat.to_param }

    context 'when logged in' do
      before do
        login watchers(:default)
      end
      it {should be_success}
      it "should give the wat" do
        subject
        assigns[:wat].should == wat
      end

      context "with a super-empty wat" do
        let(:wat) { Wat.create!(app_user: nil, sidekiq_msg: nil, request_params: nil, request_headers: nil, session: nil) }

        it {should be_success}
      end
    end
  end

  describe "POST #create" do
    let(:das_post) {post :create, format: :json , wat: {
        page_url: "somefoo",
        message: "hi",
        error_class: "ErrFoo",
        backtrace: ["a", "b", "c"],
        request_headers: {a: 1, b: 2},
        sidekiq_msg: {retry: true, class: "FooClass"},
        session: {imakey: true, imastring: "stringer"}
      }}
    subject {das_post }

    it {should be_success}
    context "the created wat" do
      subject {das_post;assigns[:wat]}
      its(:backtrace) {should == ["a", "b", "c"]}
      its(:error_class) {should == "ErrFoo"}
      its(:message) {should == "hi"}
      its(:page_url) {should == "somefoo"}
      its(:sidekiq_msg) {should == {"retry" => true, "class" => "FooClass"}}
      its(:request_headers) {should == {"a" => 1, "b" => 2}}
      its(:session) {should == {"imakey" => true, "imastring" => "stringer"}}
    end

    context "with a crazy wat" do
      let(:das_post) {post :create, format: :json , wat: {
        page_url: "somefoo",
        message: "hi",
        error_class: "ErrFoo",
        backtrace: ["a", "b", "c"],
        request_headers: {a: 1, b: 2},
        sidekiq_msg: {retry: true, class: "FooClass"},
        session: {imakey: true, imastring: "stringer"},
        language: "needmorepylons"
      }}

      it { should be_success }

      it "shouldn't make a wat" do
        expect {subject}.to_not change(Wat, :count)
      end
    end
  end
end
