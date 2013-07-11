require 'spec_helper'

describe Wat do

  describe "#filtered" do
    let(:filter_params) {{}}
    let(:scope) {Wat.all}
    subject {scope.filtered(filter_params)}
    it {should have(Wat.count).items}

    context "with an app_name" do
      let(:filter_params) {{app_name: "app1"}}
      it {should have(Wat.where(app_name: :app1).count).items}
    end

    context "with an app_env" do
      let(:filter_params) {{app_env: "demo"}}
      it {should have(Wat.where(app_env: :demo).count).items}
    end

    context "with an app_name and an app_env" do
      let(:filter_params) {{app_name: "app2", app_env: "production"}}
      it {should have(Wat.where(app_name: :app2, app_env: "production").count).items}
    end

    context "with a state" do
      let(:filter_params) {{state: :acknowledged}}
      it {should have(5).item}
    end
  end

  describe "#create!" do
    let(:error) { capture_error {raise RuntimeError.new "test message"} }

    let(:message) {error.message}
    let(:error_class) {error.class.to_s}
    let(:backtrace) { error.backtrace }
    let(:app_env) { "production" }

    subject {Wat.create!(message: error.message, error_class: error.class.to_s, backtrace: error.backtrace, app_env: app_env)}
    it { should == Wat.last }

    describe "#create_from_exception" do
      subject { Wat.create_from_exception!(error, {app_env: app_env} )}

      it                { should == Wat.last }
      its(:message)     { should == "test message"}
      its(:error_class) { should == "RuntimeError"}
      its(:app_env)     { should == "production"}
      it "should create a new wat" do
        expect {subject}.to change {Wat.count}.by(1)
      end
    end
  end

  describe "#key_line" do
    subject {wat.key_line}
    let(:wat) { wats(:default)}

    it {should match /spec/ }

    context "with an exception from a gem" do
      let(:error) {capture_error {Wat.create!(:not_a_field => 1)} }
      it {should match /spec/ }
    end
  end

  describe "construct_groupings!" do
    let(:wat) { wats(:default)}
    subject { wat.construct_groupings! }

    context "with a brand new wat" do
      let(:wat) { Wat.new_from_exception {raise RuntimeError.new 'hi'} }

      it "should create a Grouping" do
        expect {subject}.to change {Grouping.count}.by 1
      end
    end

    context "with an existing duplicate error" do
      let!(:grouping) {Grouping.where(key_line: wat.key_line, error_class: wat.error_class).first_or_create!}

      it "should not create a grouping" do
        expect {subject}.not_to change {Grouping.count}
      end

      it "should bind to the existing grouping" do
        subject
        wat.groupings.should include(grouping)
      end
    end

    context "with an existing resolved duplicate error" do
      let!(:grouping) { Grouping.where(key_line: wat.key_line, error_class: wat.error_class).first_or_create!.tap {|g| g.resolve!} }

      it "should create a grouping" do
        expect {subject}.to change {Grouping.count}.by 1
      end

      it "should not bind to the existing grouping" do
        subject
        wat.groupings.should_not include(grouping)
      end
    end
    context "with an existing acknowledged duplicate error" do
      let!(:grouping) { Grouping.where(key_line: wat.key_line, error_class: wat.error_class).first_or_create!.tap {|g| g.acknowledge!} }

      it "should create a grouping" do
        expect {subject}.to change {Grouping.count}.by 0
      end

      it "should bind to the existing grouping" do
        subject
        wat.groupings.should include(grouping)
      end
    end
  end


end