require 'spec_helper'

describe FilterSet do
  let(:current_user) { nil }
  let(:filter_params) { FilterSet.new(params: strong_params, filters: current_user.try(:default_filters), default_filters: ApplicationController::DEFAULT_FILTERS) }


  describe "#filters" do
    let(:strong_params) { ActionController::Parameters.new(params) }
    subject { filter_params.filters }

    context "params have filters" do
      let(:params) { {filters: {app_name: ["app1"]}} }
      it { should == {"app_name" => ["app1"]} }

      context "with a user with defaults" do
        let(:current_user) { watchers(:default) }
        let(:users_filters) { {app_name: ["totally_not_app1"]} }
        before { current_user.update_attributes!(default_filters: users_filters) }

        it { should == {"app_name" => ["app1"]} }
      end
    end

    context "when params don't have filters" do
      let(:params) {{}}

      context "when the user is nil" do
        it { should == ApplicationController::DEFAULT_FILTERS }
      end

      context "when the user does not have default filters" do
        let(:current_user) { watchers(:default) }
        it { should == ApplicationController::DEFAULT_FILTERS }
      end

      context "when the user has default filters" do
        let(:current_user) { watchers(:default) }
        let(:users_filters) { {app_name: ["app1"]} }
        before { current_user.update_attributes!(default_filters: users_filters) }

        it { should == users_filters }
      end
    end

    context "when there are no params" do
      let(:filter_params) { FilterSet.new(filters: current_user.try(:default_filters), default_filters: ApplicationController::DEFAULT_FILTERS) }

      context "when the user does not have default filters" do
        let(:current_user) { watchers(:default) }
        it { should == ApplicationController::DEFAULT_FILTERS }
      end

      context "when the user has default filters" do
        let(:current_user) { watchers(:default) }
        let(:users_filters) { {app_name: ["app1"]} }
        before { current_user.update_attributes!(default_filters: users_filters) }

        it { should == users_filters }
      end

    end
  end

  describe "#checked?" do
    let(:strong_params) { ActionController::Parameters.new({filters: {app_name: ["app1", "app2"]}}) }
    subject { filter_params.checked?(key, value) }

    context "when the key exists" do
      let(:key) { :app_name }
      context "when the value is in the key's list" do
        let(:value) { "app1" }

        it { should == true }
      end

      context "when the value isn't in the key's list" do
        let(:value) { "app_not_an_app" }
        it { should == false }
      end
    end

    context "when the key doesn't exist" do
      let(:key) { :nonesuch_key }
      let(:value) { "why_even_care" }

      it { should == false }
    end
  end
end
