require 'spec_helper'

describe GroupingUnsubscribesController, :type => :controller do
  let(:watcher) {watchers :default}
  let(:grouping) {groupings(:grouping1)}

  before { @request.env['HTTP_REFERER'] = '/something'  }

  describe "POST #create" do
    subject { post :create, grouping_id: grouping.id }

    context "when logged in" do
      before do
        login watcher
      end

      it "should create an unsubscribe record for that grouping" do
        expect{subject}.to change { watcher.grouping_unsubscribes.where(grouping: grouping).count }.by 1
      end

      context "when there is already an unsubscribe" do
        before {watcher.grouping_unsubscribes.create!(grouping: grouping)}

        it "should NOT create an unsubscribe record for that grouping" do
          expect{subject}.to raise_error ActiveRecord::RecordNotUnique
        end
      end
    end
  end


  describe "DELETE #destroy" do
    subject { delete :destroy, id: grouping_unsubscribe.id }

    context "when logged in" do
      before do
        login watcher
      end

      context "when there is already an unsubscribe" do
        let!(:grouping_unsubscribe) {watcher.grouping_unsubscribes.create!(grouping: grouping)}

        it "should remove the unsubscribe record for that grouping" do
          expect{subject}.to change {grouping.unsubscribed?(watcher)}.to false
        end
      end
    end
  end
end
