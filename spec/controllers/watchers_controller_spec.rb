require 'spec_helper'

describe WatchersController, :type => :controller do
  describe "PATCH #update" do
    let(:watcher) { watchers(:another_watcher) }

    let(:params) do
      { watcher: {default_filters: { language: [:ruby] } }}
    end

    subject do
      patch :update, params.merge(id: watcher.to_param)
    end
    before do
      @request.env['HTTP_REFERER'] = '/something'
    end

    context 'when logged in' do
      before do
        login current_user
      end

      context "when the current user is changing their own filters" do
        let(:current_user) {watcher}

        context "with both default and email filters" do
          before do
            current_user.update_attributes!(
                default_filters: { language: [:ruby] },
                email_filters:   {language:  [:javascript]}
            )
          end
          context "changing their default_filters" do
            let(:params) { { watcher: {default_filters: { language: [:javascript] } }} }

            let(:current_user) {watcher}

            it { should redirect_to '/something' }

            it "doesn't change their email filters" do
              expect {
                  subject
              }.to_not change {watcher.reload.email_filters}
            end

            it "changes their default filters" do
              expect {
                subject
              }.to change {watcher.reload.default_filters}
            end
          end
          context "when changing their email filters" do
            let(:params) { { watcher: {email_filters: { language: [:ruby] } }} }


            it { should redirect_to '/something' }

            it "changes their email filters" do
              expect {
                subject
              }.to change {watcher.reload.email_filters}
            end

            it "doesn't change their default filters" do
              expect {
                subject
              }.to_not change {watcher.reload.default_filters}
            end
          end

          context "when changing both email and default filters" do
            let(:params) do
              { watcher: {
                default_filters: { language: [:javascript] },
                email_filters:   {language:  [:ruby]}
              }}
            end

            it "changes their email filters" do
              expect {
                subject
              }.to change {watcher.reload.email_filters}
            end

            it "changes their default filters" do
              expect {
                subject
              }.to change {watcher.reload.default_filters}
            end
          end
        end
      end

      context "when the current user is trying to change someone else's filters" do
        let(:current_user) { watchers(:default) }

        it { should redirect_to '/something' }

        it "does not change anyone's default filters" do
          subject
          expect(watcher.reload.default_filters).to be_nil
          expect(current_user.reload.default_filters).to be_nil
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
        expect(assigns[:watchers]).to have(Watcher.count).items
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
        expect(assigns[:watcher]).to eq watcher
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
