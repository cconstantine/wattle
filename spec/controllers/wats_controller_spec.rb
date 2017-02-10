require 'spec_helper'

describe WatsController, :type => :controller do
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
        expect(assigns[:wats]).to have(Wat.count).items
      end
    end

    context 'when supplying a valid api token' do
      subject { get :index, per_page: 100, api_key: token}
      let(:token) { TokenSource.new.generate }
      before do
        watchers(:default).update_column :api_key, token
      end

      it "should get all wats" do
        subject
        expect(assigns[:wats]).to have(Wat.count).items
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
        expect(assigns[:wat]).to eq wat
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
        sidekiq_msg: {retry: false, class: "FooClass"},
        session: {imakey: true, imastring: "stringer"}
      }}
    subject {das_post }

    it "should queue a job" do
      subject
      expect(WatsController::CreateNonProdWatWorker).to have(1).enqueued.job
    end

    context "when getting a production wat" do
      let(:das_post) {post :create, format: :json , wat: {
          app_env: "production",
          page_url: "somefoo",
          message: "hi",
          error_class: "ErrFoo",
          backtrace: ["a", "b", "c"],
          request_headers: {a: 1, b: 2},
          sidekiq_msg: {retry: false, class: "FooClass"},
          session: {imakey: true, imastring: "stringer"}
      }}

      it "should queue a production job" do
        subject
        expect(WatsController::CreateProdWatWorker).to have(1).enqueued.job
      end
    end

    it "shouldn't do any reindexing" do
      allow_any_instance_of(Grouping).to receive(:reindex) { raise RuntimeError.new "Should not get called" }
      subject
      WatsController::CreateWatWorker.drain
    end

    context "with sidekiq running inline", sidekiq: :inline do

      it {should be_success}


      context "the created wat" do
        subject {das_post;Wat.last}
        it { expect(subject.backtrace).to eq( ["a", "b", "c"] )}
        it { expect(subject.error_class).to eq  "ErrFoo" }
        it { expect(subject.message).to eq  "hi" }
        it { expect(subject.page_url).to eq  "somefoo" }
        it { expect(subject.sidekiq_msg).to eq({"retry" => "false", "class" => "FooClass"}) }
        it { expect(subject.request_headers).to eq ({"a" => "1", "b" => "2"})}
        it { expect(subject.session).to eq( {"imakey" => "true", "imastring" => "stringer"})}
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

      context "with a wat that still has sidekiq retries left" do
        let(:das_post) {post :create, format: :json , wat: {
            sidekiq_msg: {retry: true, class: "FooClass", retry_count: "2"},
            language: "ruby"
          }}

        it { should be_success }

        it "shouldn't make a wat" do
          expect {subject}.to_not change(Wat, :count)
        end
      end
    end
  end
end
