require 'spec_helper'

describe GroupingsController do
  let(:error) { capture_error {raise RuntimeError.new "test message"} }

  let(:message) {error.message}
  let(:error_class) {error.class.to_s}
  let(:backtrace) { error.backtrace }

  describe "GET #index" do
    subject { get :index, format: :json }

    it "should require login" do
      subject.should redirect_to auth_path
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
          assigns[:groupings].to_a.should have(Grouping.open.count).items
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

      context "filtering wats" do
        let(:filters) { { :app_env => "demo" } }
        it "filters the wats" do
          subject
          expect(controller.wats(assigns[:grouping])).to have(5).items
          controller.wats(assigns[:grouping]).pluck(:app_env).uniq.should == ['demo']
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

  describe "POST #acknowledge" do
    let(:wat) { grouping.wats.first}
    let(:grouping) {groupings(:grouping2)}

    subject do
      @request.env['HTTP_REFERER'] = '/something'
      post :acknowledge, id: grouping.to_param, format: :json
    end

    context "when logged in" do
      before do
        login watchers(:default)
      end

      it {should redirect_to '/something'}
      it "should resolve the grouping" do
        expect {subject}.to change {grouping.reload.acknowledged?}.from(false).to(true)
      end

      context "with a acknowledged grouping" do
        let(:grouping) {groupings(:acknowledged)}
        it "should raise and error" do
          expect{subject}.to raise_error StateMachine::InvalidTransition
        end
      end
    end
  end

  describe "POST #activate" do
    let(:wat) { grouping.wats.first}
    let(:grouping) {groupings(:acknowledged)}

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

      context "with a acknowledged grouping" do
        let(:grouping) {groupings(:grouping1)}
        it "should raise and error" do
          expect{subject}.to raise_error StateMachine::InvalidTransition
        end
      end
    end
  end

end
