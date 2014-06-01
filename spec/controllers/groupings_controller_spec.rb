require 'spec_helper'

describe GroupingsController do
  render_views

  let(:error) { capture_error {raise RuntimeError.new "test message"} }

  let(:message) {error.message}
  let(:error_class) {error.class.to_s}
  let(:backtrace) { error.backtrace }

  describe "GET #index" do
    subject { get :index, format: :json }
    context "using real auth" do
      before { stub(controller).use_developer_auth? {false } }

      it "should require login" do
        subject.should redirect_to auth_path
      end
    end

    context "when logged in" do
      before do
        login watchers(:default)
      end

      it {should be_success}

      context "groupings" do
        subject { get :index, params }
        let(:grouping1)  {groupings(:group)}
        let(:demo_group) {groupings(:demo_grouping)}
        let(:params) { {} }

        it "should include unfiltered groupings" do
          subject
          assigns[:groupings].to_a.should have(Grouping.open.unmerged.count).items
          assigns[:groupings].to_a.map(&:app_envs).flatten.uniq.should =~ ['demo', 'production', 'staging']
        end

        context "filtered" do
          let(:params) { {filters: { :app_env => "staging" }} }
          it "should include filtered groupings" do
            subject

            assigns[:groupings].
                to_a.
                map(&:wats).
                flatten.
                map(&:app_env).
                uniq.
                should =~ ['staging']
          end
        end
        context "ordering" do
          subject { get :index, order: order }
          let(:hottest) { Grouping.order(:popularity).last }
          let(:newest) { Grouping.wat_order.reverse.first }

          #sanity check
          it "should not be that hottest and newest are the same grouping" do
            hottest.should_not == newest
          end

          context "without a specified order, page is new" do
            let(:order) {nil}
            it "should show the newest groupings first" do
              subject
              assigns[:groupings].first.should == newest
            end
          end

          context "page is hot" do
            let(:order) {:hot}
            it "should show the hottest groupings first" do
              subject
              assigns[:groupings].first.should == hottest
            end
          end

          context "page is new" do
            let(:order) {:new}
            it "should show the newest groupings first" do
              subject
              assigns[:groupings].first.should == newest
            end
          end
        end
      end

    end

  end

  describe "GET #show" do
    let(:wat) { grouping.wats.last}
    let(:grouping) {groupings(:grouping3)}
    let(:filters) {{}}

    subject {get :show, id: grouping.to_param, filters: filters, format: :json }
    context "when logged in" do
      before do
        login watchers(:default)
      end
      it {should be_success}
      it "should load the grouping" do
        subject
        assigns[:grouping].should == grouping
      end
    end
  end

  describe "POST #create" do

    subject { post :create, grouping_ids: grouping_ids, grouping: { state: "active" } }

    context "when logged in" do
      before do
        login watchers(:default)
      end

      context "with valid grouping info" do
        let(:child1) { groupings :grouping1 }
        let(:child2) { groupings :grouping2 }
        let(:grouping_ids) { [child1.id, child2.id] }

        it "merges the groupings" do
          pending "`receive' apparently is bonkers"
          # WAT
          expect(Grouping).to receive(:merge!)#.with([child1, child2])
          subject
        end

        it "creates a new grouping" do
          expect{ subject }.to change(Grouping, :count).by(1)
        end

        it "redirects to the new grouping" do
          expect(subject).to redirect_to Grouping.last
        end
      end

      context "with invalid grouping info" do
        let(:grouping_ids) { [-2, -1] }

        it "does not create a new grouping" do
          expect{ begin; subject; rescue; end }.not_to change(Grouping, :count)
        end

        it "raises an error" do
          expect { subject }.to raise_error ActiveRecord::RecordNotFound
        end
      end
    end
  end

  describe "POST #resolve" do
    let(:wat) { grouping.wats.first}
    let(:grouping) {groupings(:grouping2)}

    subject do
      @request.env['HTTP_REFERER'] = '/something'
      post :resolve, id: grouping.to_param, format: :json
    end

    context "when logged in" do
      before do
        login watchers(:default)
      end

      it {should redirect_to '/something'}
      it "should resolve the grouping" do
        expect {subject}.to change {grouping.reload.resolved?}.from(false).to(true)
      end

      context "with a resolved grouping" do
        let(:grouping) {groupings(:resolved)}
        it "should raise and error" do
          expect{subject}.to raise_error StateMachine::InvalidTransition
        end
      end
    end
  end

  describe "POST #wontfix" do
    let(:wat) { grouping.wats.first}
    let(:grouping) {groupings(:grouping2)}

    subject do
      @request.env['HTTP_REFERER'] = '/something'
      post :wontfix, id: grouping.to_param, format: :json
    end

    context "when logged in" do
      before do
        login watchers(:default)
      end

      it {should redirect_to '/something'}
      it "should resolve the grouping" do
        expect {subject}.to change {grouping.reload.wontfix?}.from(false).to(true)
      end

      context "with a wontfix grouping" do
        let(:grouping) {groupings(:wontfix)}
        it "should raise and error" do
          expect{subject}.to raise_error StateMachine::InvalidTransition
        end
      end
    end
  end

  describe "POST #activate" do
    let(:wat) { grouping.wats.first}
    let(:grouping) {groupings(:wontfix)}

    subject do
      @request.env['HTTP_REFERER'] = '/something'
      post :activate, id: grouping.to_param, format: :json
    end

    context "when logged in" do
      before do
        login watchers(:default)
      end

      it {should redirect_to '/something'}
      it "should resolve the grouping" do
        expect {subject}.to change {grouping.reload.active?}.from(false).to(true)
      end

      context "with a wontfix grouping" do
        let(:grouping) {groupings(:grouping1)}
        it "should raise and error" do
          expect{subject}.to raise_error StateMachine::InvalidTransition
        end
      end
    end
  end

  describe "POST #muffle" do
    let(:wat) { grouping.wats.first}
    let(:grouping) {groupings(:grouping2)}

    subject do
      @request.env['HTTP_REFERER'] = '/something'
      post :muffle, id: grouping.to_param, format: :json
    end

    context "when logged in" do
      before do
        login watchers(:default)
      end

      it {should redirect_to '/something'}
      it "should muffle the grouping" do
        expect {subject}.to change {grouping.reload.muffled?}.from(false).to(true)
      end
    end
  end

  describe "DELETE #destroy" do

    subject { delete :destroy, id: grouping.id }

    context "when logged in" do
      before do
        login watchers(:default)
      end

      context "with a manually created (merged) grouping" do
        let!(:grouping) { groupings :merged_grouping }
        let!(:subgrouping_ids) { grouping.subgroupings.map(&:id) }

        it "destroys the grouping" do
          subject
          expect{ grouping.reload }.to raise_error ActiveRecord::RecordNotFound
        end

        it "marks subgroupings as unmerged" do
          subject
          expect(Grouping.find(subgrouping_ids).map(&:merged_into_grouping_id)).to match_array [nil,nil]
        end

        it { should redirect_to groupings_path }
      end

      context "with a normal grouping" do
        let!(:grouping) { groupings :grouping1 }

        it "doesn't destroy the grouping" do
          subject
          expect{ grouping.reload }.not_to raise_error
        end

        it "displays an error message" do
          subject
          expect(flash[:alert]).to be_present
        end

        it { should redirect_to grouping }
      end
    end
  end
end
