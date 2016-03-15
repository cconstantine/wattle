require 'spec_helper'

RSpec.describe SearchesController, type: :controller do

  describe "GET #show" do
    subject { get :show }
    context "using real auth" do
      before { allow(controller).to receive(:use_developer_auth?) { false } }

      it "should require login" do
        is_expected.to redirect_to auth_path
      end
    end

    context "when logged in" do
      let(:watcher) { watchers :default }

      before do
        login watcher
      end

      it { should be_success }

      context "without a search query" do
        it "should have an empty results" do
          subject
          expect(assigns[:search_results]).to have(Grouping.count).items
        end
      end

      context "with a search query" do
        subject { get :show, q: "a test"}

        it "should have an populated results object" do
          subject
          expect(assigns[:search_results]).to_not be_empty
        end
      end
    end

  end

end
