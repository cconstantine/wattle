require 'spec_helper'

describe WatchersController do
  render_views

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
