require 'spec_helper'

describe WatchersController do
  render_views

  describe "PATCH #update" do
    let(:watcher) { watchers(:another_watcher) }
    subject {patch :update, id: watcher.to_param, filters: { language: [:ruby] } }
    before { @request.env['HTTP_REFERER'] = '/something' }

    context 'when logged in' do
      before do
        login current_user
      end

      context "when the current user is changing their own filters" do
        let(:current_user) {watcher}

        it { should redirect_to '/something' }

        it "changes their default filters" do
          expect {subject}.to change {watcher.reload.default_filters}
        end
      end

      context "when the current user is trying to change someone else's filters" do
        let(:current_user) { watchers(:default) }

        it { should redirect_to '/something' }

        it "does not change anyone's default filters" do
          subject
          expect(watcher.reload.default_filters).to be_nil
          expect(watchers(:default).default_filters).to be_nil
        end
      end
    end
  end

  describe "GET #index" do
    subject { get :index, per_page: 100}
    context 'when logged in' do
      before do
        login watchers(:default)
      end

      it {should be_success}


      it "should get all watchers" do
        subject
        assigns[:watchers].should have(Watcher.count).items
      end
    end
  end

  describe "GET #show" do
    let(:watcher) { watchers(:default) }
    subject { get :show, id: watcher.to_param }

    context 'when logged in' do
      before do
        login watchers(:default)
      end

      it {should be_success}
      it "should give the watcher" do
        subject
        assigns[:watcher].should == watcher
      end
    end
  end


  describe "POST #reactivate" do
    let(:watcher) { watchers(:inactive) }
    subject { post :reactivate, id: watcher.to_param }

    context 'when logged in' do
      before do
        login watchers(:default)
        @request.env['HTTP_REFERER'] = '/something'
      end

      it {should be_redirect}
      it "should reactivate the watcher" do
        expect {subject}.to change {watcher.reload.state}.to "active"
      end
    end
  end

  describe "POST #deactivate" do
    let(:watcher) { watchers(:default) }
    subject { post :deactivate, id: watcher.to_param }

    context 'when logged in' do
      before do
        login watchers(:default)
        @request.env['HTTP_REFERER'] = '/something'
      end

      it {should be_redirect}
      it "should deactivate the watcher" do
        expect {subject}.to change {watcher.reload.state}.to "inactive"
      end
    end
  end
end
