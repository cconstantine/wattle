require 'spec_helper'

describe Api::GroupingsController, type: :controller do
  let(:watcher) { watchers(:default) }

  before do
    login watcher
  end

  describe "#count_by_state" do 
    context "with correct params" do 
      let(:app_name) { "app1" }
      subject { get :count_by_state, format: :json, app_name:app_name }

      context "when app with wats" do
        it "return the right count of every groupings state" do
          subject
          scoped_grouping = Grouping.app_name(app_name)
          expect(response.body).to be_json_eql({ unacknowledged: scoped_grouping.unacknowledged.count, acknowledged: scoped_grouping.state(:acknowledged).count, deprioritized: scoped_grouping.deprioritized.count, resolved: scoped_grouping.resolved.count }.to_json)
        end
      end
    end
    context 'without :app_name params' do
      subject { get :count_by_state, format: :json }

      it { is_expected.not_to be_success }
    end
  end
end