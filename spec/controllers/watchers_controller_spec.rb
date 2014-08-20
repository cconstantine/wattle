require 'spec_helper'

describe WatchersController do
  render_views

  describe "PATCH #update" do
    let(:watcher) { watchers(:another_watcher) }

    let(:original_default_filters) { { "language" => ["ruby"] } }
    let(:original_email_filters) { { "language" => ["javascript"] } }

    let(:original_default_filter_params) { { "language" => { "ruby" => "1" } } }
    let(:original_email_filter_params) { { "language" => { "javascript" => "1" } } }

    subject do
      patch :update, params.merge(id: watcher.to_param)
    end

    before do
      @request.env["HTTP_REFERER"] = "/something"
    end

    context "when not logged in" do
      let(:params) { {} }

      it "asks you to log in" do
        subject
        expect(response).to redirect_to("/auth/developer")
      end
    end

    context "when logged in" do
      before do
        login current_user
      end

      context "when the current user is changing their own filters" do
        let(:current_user) { watcher }

        before do
          current_user.update_attributes!(
            "default_filters" => original_default_filters,
            "email_filters" => original_email_filters
          )
        end

        context "when removing all default filters" do
          let(:params) { { watcher: {
            "default_filters" => { "language" => { "erlang" => "0", "ruby" => "0" } },
            "email_filters" => original_email_filter_params
          } } }

          it "removes all filters" do
            expect { subject }.to change { watcher.reload.default_filters }.to("language" => [])
          end
        end

        context "changing their default_filters" do
          let(:params) { { watcher: {
            "email_filters" => original_email_filter_params,
            "default_filters" => { "language" => { "erlang" => "1", "ruby" => "0" } }
          } } }

          let(:current_user) { watcher }

          it { should redirect_to("/something") }

          it "doesn't change their email filters" do
            expect { subject }.to_not change { watcher.reload.email_filters }
          end

          it "changes their default filters" do
            expect { subject }.to change { watcher.reload.default_filters }
            expect(watcher.default_filters["language"]).to eq(["erlang"])
          end
        end

        context "changing their email filters" do
          let(:params) { { watcher: {
            "email_filters" => { "language" => { "go" => "1" } },
            "default_filters" => original_default_filter_params
          } } }

          it { should redirect_to "/something" }

          it "changes their email filters" do
            expect { subject }.to change { watcher.reload.email_filters }
            expect(watcher.email_filters["language"]).to eq(["go"])
          end

          it "doesn't change their default filters" do
            expect { subject }.to_not change { watcher.reload.default_filters }
          end
        end

        context "changing both email and default filters" do
          let(:params) do
            { watcher: {
              "default_filters" => { "language" => { "scala" => "1", "f#" => "0" } },
              "email_filters" => { "language" => { "scala" => "1", "f#" => "0" } },
            } }
          end

          it "changes their email filters" do
            expect { subject }.to change { watcher.reload.email_filters }
          end

          it "changes their default filters" do
            expect { subject }.to change { watcher.reload.default_filters }
          end
        end
      end

      context "when the current user is trying to change someone else's filters" do
        let(:params) { {} }
        let(:current_user) { watchers(:default) }

        it { should redirect_to "/something" }

        it "does not change anyone's default filters" do
          subject
          expect(watcher.reload.default_filters).to be_nil
          expect(current_user.reload.default_filters).to be_nil
        end
      end
    end
  end

  describe "GET #index" do
    subject { get :index, per_page: 100 }

    context "when logged in" do
      before do
        login watchers(:default)
      end

      it { should be_success }

      it "gets all watchers" do
        subject
        expect(assigns[:watchers]).to eq(Watcher.all)
      end
    end
  end

  describe "GET #show" do
    let(:watcher) { watchers(:default) }
    subject { get :show, id: watcher.to_param }

    context "when logged in" do
      before do
        login watchers(:default)
      end

      it { should be_success }

      it "assigns the watcher" do
        subject
        expect(assigns[:watcher]).to eq watcher
      end
    end
  end


  describe "POST #reactivate" do
    let(:watcher) { watchers(:inactive) }
    subject { post :reactivate, id: watcher.to_param }

    context "when logged in" do
      before do
        login watchers(:default)
        @request.env["HTTP_REFERER"] = "/something"
      end

      it { should be_redirect }
      it "should reactivate the watcher" do
        expect { subject }.to change { watcher.reload.state }.to "active"
      end
    end
  end

  describe "POST #deactivate" do
    let(:watcher) { watchers(:default) }
    subject { post :deactivate, id: watcher.to_param }

    context "when logged in" do
      before do
        login watchers(:default)
        @request.env["HTTP_REFERER"] = "/something"
      end

      it { should be_redirect }
      it "should deactivate the watcher" do
        expect { subject }.to change { watcher.reload.state }.to "inactive"
      end
    end
  end
end
