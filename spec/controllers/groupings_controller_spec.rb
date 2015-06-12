require 'spec_helper'

describe GroupingsController, versioning: true, :type => :controller do
  let(:error) { capture_error { raise RuntimeError.new "test message" } }

  let(:message) { error.message }
  let(:error_class) { error.class.to_s }
  let(:backtrace) { error.backtrace }
  let(:watcher) { watchers :default }

  describe "GET #index" do
    subject { get :index }
    context "using real auth" do
      before { allow(controller).to receive(:use_developer_auth?) { false } }

      it "should require login" do
        is_expected.to redirect_to auth_path
      end
    end

    context "when logged in" do
      before do
        login watcher
      end

      it { should be_success }

      context "groupings" do
        subject { get :index, params }
        let(:grouping1) { groupings(:group) }
        let(:demo_group) { groupings(:demo_grouping) }
        let(:params) { {} }

        it "should include unfiltered groupings" do
          subject
          expect(assigns[:groupings].to_a).to have(Grouping.filtered(ApplicationController::DEFAULT_FILTERS).count).items
          expect(assigns[:groupings].to_a.map(&:app_envs).flatten.uniq).to match_array ['demo', 'production', 'staging']
        end

        context "filtered" do
          let(:params) { {filters: {:app_env => "staging"}} }
          it "should include filtered groupings" do
            subject

            expect(assigns[:groupings].
                    to_a.
                    map(&:wats).
                    flatten.
                    map(&:app_env).
                    uniq).to match_array ['staging']
          end
        end
        context "ordering" do
          subject { get :index, order: order }
          let(:newest) { Grouping.wat_order.reverse.first }


          context "without a specified order, page is new" do
            let(:order) { nil }
            it "should show the newest groupings first" do
              subject
              expect(assigns[:groupings].first).to eq newest
            end
          end
        end
      end

    end

  end

  describe "GET #show" do
    let(:wat) { grouping.wats.last }
    let(:grouping) { groupings(:grouping3) }
    let(:filters) { {} }

    subject { get :show, id: grouping.to_param, filters: filters }
    context "when logged in" do
      before do
        login watcher
      end
      it { should be_success }
      it "should load the grouping" do
        subject
        expect(assigns[:grouping]).to eq grouping
      end

      context "a grouping with wat users and browsers" do
        let(:grouping) { groupings(:grouping4) }
        it "succeeds" do
          subject
          expect(response).to be_success
        end

      end

      context "when it is acknowledged with a note" do
        before do
          grouping.acknowledge!
          grouping.notes.create!(watcher: watcher, message: "Derpy dper dperkjdf")
        end

        it "should have some stream_events" do
          subject
          expect(assigns[:stream_events]).to have(2).items
        end
      end
    end
  end

  describe "POST #resolve" do
    let(:wat) { grouping.wats.first }
    let(:grouping) { groupings(:grouping2) }

    subject do
      @request.env['HTTP_REFERER'] = '/something'
      post :resolve, id: grouping.to_param
    end

    context "when logged in" do
      let(:watcher) { watchers(:default) }
      before do
        login watcher
      end

      it "should save the papertrail" do
        expect { subject }.to change { grouping.versions.count }.by 1
        expect(grouping.reload.versions.last.watcher).to eq watcher
      end

      it { should redirect_to '/something' }
      it "should resolve the grouping" do
        expect { subject }.to change { grouping.reload.resolved? }.from(false).to(true)
      end

      context "with a resolved grouping" do
        let(:grouping) { groupings(:resolved) }
        it "should raise and error" do
          expect { subject }.to raise_error StateMachine::InvalidTransition
        end
      end
    end
  end

  describe "POST #wontfix" do
    let(:wat) { grouping.wats.first }
    let(:grouping) { groupings(:grouping2) }

    subject do
      @request.env['HTTP_REFERER'] = '/something'
      post :wontfix, id: grouping.to_param
    end

    context "when logged in" do
      before do
        login watcher
      end

      it "should save the papertrail" do
        expect { subject }.to change { grouping.versions.count }.by 1
        expect(grouping.reload.versions.last.watcher).to eq watcher
      end

      it { should redirect_to '/something' }
      it "should resolve the grouping" do
        expect { subject }.to change { grouping.reload.wontfix? }.from(false).to(true)
      end

      context "with a wontfix grouping" do
        let(:grouping) { groupings(:wontfix) }
        it "should raise and error" do
          expect { subject }.to raise_error StateMachine::InvalidTransition
        end
      end
    end
  end

  describe "POST #activate" do
    let(:wat) { grouping.wats.first }
    let(:grouping) { groupings(:wontfix) }

    subject do
      @request.env['HTTP_REFERER'] = '/something'
      post :activate, id: grouping.to_param
    end

    context "when logged in" do
      before do
        login watcher
      end

      it "should save the papertrail" do
        expect { subject }.to change { grouping.versions.count }.by 1
        expect(grouping.reload.versions.last.watcher).to eq watcher
      end

      it { should redirect_to '/something' }
      it "should resolve the grouping" do
        expect { subject }.to change { grouping.reload.unacknowledged? }.from(false).to(true)
      end

      context "with a wontfix grouping" do
        let(:grouping) { groupings(:grouping1) }
        it "should raise and error" do
          expect { subject }.to raise_error StateMachine::InvalidTransition
        end
      end
    end
  end

  describe "POST #acknowledge" do
    let(:wat) { grouping.wats.first }
    let(:grouping) { groupings(:grouping2) }

    subject do
      @request.env['HTTP_REFERER'] = '/something'
      post :acknowledge, id: grouping.to_param
    end


    context "when logged in" do
      before do
        login watcher
      end

      it "should save the papertrail" do
        expect { subject }.to change { grouping.versions.count }.by 1
        expect(grouping.reload.versions.last.watcher).to eq watcher
      end

      it { should redirect_to '/something' }
      it "should acknowledge the grouping" do
        expect { subject }.to change { grouping.reload.acknowledged? }.from(false).to(true)
      end
    end
  end

end
