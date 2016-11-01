require 'spec_helper'

describe Api::GroupingsController, type: :controller do
  let(:watcher) { watchers(:default) }
  let(:app_name) { "app1" }
  let(:scoped_grouping) { Grouping.app_name(app_name).app_env('production').language('ruby') }

  before do
    login watcher
  end

  describe "#count_by_state" do
    context "with correct params" do
      subject { get :count_by_state, format: :json, app_name: app_name, app_env: 'production', language: 'ruby' }

      context "when app with wats" do
        it "return the right count of every groupings state" do
          subject
          expect(response.body).to be_json_eql({ unacknowledged: scoped_grouping.unacknowledged.count, acknowledged: scoped_grouping.state(:acknowledged).count, deprioritized: scoped_grouping.deprioritized.count, resolved: scoped_grouping.resolved.count }.to_json)
        end
      end
    end
    context 'without :app_name params' do
      subject { get :count_by_state, app_env: 'test', language: 'ruby', format: :json }

      it { is_expected.not_to be_success }
    end
    context 'without :app_env params' do
      subject { get :count_by_state, app_name: app_name, language: 'ruby', format: :json }

      it { is_expected.not_to be_success }
    end
    context 'without :language params' do
      subject { get :count_by_state, app_name: app_name, app_env: 'test', format: :json }

      it { is_expected.not_to be_success }
    end
  end

  describe "#count" do
    let(:state) { :acknowledged }
    let(:params) { { format: :json, app_name: app_name, app_env: 'production', language: 'ruby', state: state } }

    it "return the right count of groupings in the acknowledged state" do
      get :count, params
      expect(response.body).to be_json_eql({ state: state, count: scoped_grouping.acknowledged.count }.to_json)
    end
    context 'without :app_name params' do
      subject { get :count, params.except(:app_name) }

      it { is_expected.not_to be_success }
    end
    context 'without :app_env params' do
      subject { get :count, params.except(:app_env) }

      it { is_expected.not_to be_success }
    end
    context 'without :language params' do
      subject { get :count, params.except(:language) }

      it { is_expected.not_to be_success }
    end
  end
end
