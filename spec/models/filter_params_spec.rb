require 'spec_helper'

describe FilterParams do
  let(:filter_params) {FilterParams.new(strong_params)}

  describe "#checked?" do
    let(:strong_params) {ActionController::Parameters.new({ filters: { app_name: ["app1", "app2"] } })}
    subject { filter_params.checked?(key, value) }

    context "when the key exists" do
      let(:key) { :app_name }
      context "when the value is in the key's list" do
        let(:value) { "app1" }

        it { should == true }
      end

      context "when the value isn't in the key's list" do
        let(:value) { "app_not_an_app" }
        it { should == false}
      end
    end

    context "when the key doesn't exist" do
      let(:key) { :nonesuch_key }
      let(:value) { "why_even_care" }

      it { should == true}
    end
  end
end
