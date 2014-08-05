require 'spec_helper'

describe GroupingOwnersController do
  render_views

  let(:watcher) {watchers :default}
  let(:grouping) {groupings(:grouping1)}

  before { @request.env['HTTP_REFERER'] = '/something'  }

  describe "POST #create" do
    subject { post :create, grouping_id: grouping.id }

    context "when logged in" do
      before do
        login watcher
      end

      it "should create an ownership record for that grouping" do
        expect{subject}.to change { watcher.owned_groupings.count }.by 1
      end

      context "when there is already an owner" do
        before {watcher.grouping_owners.create!(grouping: grouping)}

        it "should NOT create an unsubscribe record for that grouping" do
          expect{subject}.to raise_error ActiveRecord::RecordNotUnique
        end
      end
    end
  end


  describe "DELETE #destroy" do
    subject { delete :destroy, id: grouping_owner.id }

    context "when logged in" do
      before do
        login watcher
      end

      context "when there is already an unsubscribe" do
        let!(:grouping_owner) {watcher.grouping_owners.create!(grouping: grouping)}

        it "should remove the unsubscribe record for that grouping" do
          expect{subject}.to change { watcher.owned_groupings.count }.by -1
        end
      end
    end
  end
end
