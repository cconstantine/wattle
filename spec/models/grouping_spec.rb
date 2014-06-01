require 'spec_helper'

describe Grouping do

  let(:error) { capture_error {raise RuntimeError.new "test message"} }

  let(:message) {error.message}
  let(:error_class) {error.class.to_s}
  let(:backtrace) { error.backtrace }
  let(:app_env) { 'production' }
  let(:metadata) { { app_env: app_env, language: :ruby } }

  let(:wat) {Wat.new_from_exception(error, metadata) }


  describe ".by_user" do
    subject {Grouping.by_user(user_id)}

    let(:user_id) {"2"}
    it {should have(1).item}
  end

  describe ".merge!" do
    let(:child1) { groupings(:grouping1) }
    let(:child2) { groupings(:grouping2) }
    let(:child_groupings) { [child1, child2] }
    let(:new_grouping_attributes) { { state: "muffled" } }
    let(:new_grouping) { Grouping.last }

    subject { Grouping.merge! child_groupings, new_grouping_attributes }

    describe "the new grouping" do
      it "has the expected child groupings" do
        subject
        expect(new_grouping.subgroupings).to match_array [child1, child2]
        expected_wats_count = (child1.wats + child2.wats).uniq.count
        expect(new_grouping.wats.count).to eq expected_wats_count
        expect(child1.merged_into_grouping).to eq new_grouping
      end

      it "has the expected state" do
        subject
        expect(new_grouping.state).to eq "muffled"
      end
    end
  end

  describe "#new_wats" do
    let(:grouping) {groupings(:grouping1)}
    subject {grouping.new_wats}
    context "with a nil last_emailed_at" do
      before { grouping.update_column(:last_emailed_at, nil)}
      it { should have(5).items }
    end
    context "with a last_emailed_at between the latest and 2nd to lastest wat" do
      before {grouping.update_column(:last_emailed_at, grouping.wats.order('id desc').limit(2).last.created_at)}
      it {should have(1).item}
    end
    context "with a last_emailed_at before the latest wat" do
      before {grouping.update_column(:last_emailed_at, grouping.wats.minimum(:created_at) - 1.second)}
      it {should have(5).item}
    end

  end

  describe "#app_user_stats" do
    subject {grouping.app_user_stats()}
    context "with no app_user info" do
      let(:grouping) {groupings(:grouping1)}
      it {should == {nil => 5}}
    end

    context "with some interesting app_user info" do
      let(:grouping) {groupings(:grouping4)}
      it {should == {nil => 2, "2" => 2, "1" => 1}}
    end
  end

  describe "#app_user_count" do
    subject {grouping.app_user_count()}
    context "with no app_user info" do
      let(:grouping) {groupings(:grouping1)}
      it {should == 0}
    end

    context "with some interesting app_user info" do
      let(:grouping) {groupings(:grouping4)}
      it {should == 2}
    end
  end

  describe "#browser_stats" do
    subject {grouping.browser_stats()}
    context "with no browser info" do
      let(:grouping) {groupings(:grouping1)}
      it {should == {nil => 5}}
    end

    context "with some interesting browser info" do
      let(:grouping) {groupings(:grouping4)}
      it {should == {nil => 2, "FooBrowser" => 2, "Barser" => 1}}
    end
  end

  describe "#browser_count" do
    subject {grouping.browser_count()}
    context "with no browser info" do
      let(:grouping) {groupings(:grouping1)}
      it {should == 0}
    end

    context "with some interesting browser info" do
      let(:grouping) {groupings(:grouping4)}
      it {should == 2}
    end
  end


  describe "#filtered" do
    let(:filter_params) {{}}
    let(:scope) {Grouping.all}
    subject {scope.filtered(filter_params)}
    it {should have(Grouping.open.unmerged.count).items}

    context "with an app_user" do
      let(:filter_params) {{app_user: "2"}}
      it {should have(1).items}
    end

    context "with an app_name" do
      let(:filter_params) {{app_name: "app1"}}
      it {should have(5).items}
    end

    context "with an app_env" do
      let(:filter_params) {{app_env: "demo"}}
      it {should have(Grouping.open.app_env(:demo).count).items}
    end

    context "with an app_name and an app_env" do
      let(:filter_params) {{app_name: "app2", app_env: "production"}}
      it {should have(Grouping.open.app_name(:app2).app_env("production").count).items}
    end

    context "with a state" do
      let(:filter_params) {{state: :wontfix}}
      it {should have(1).item}
      context "with an app_name" do
        let(:filter_params) {{state: :wontfix, app_name: :app1}}
        it {should have(1).item}
      end

      context "with an app_env" do
        let(:filter_params) {{state: :wontfix, app_env: :production}}
        it {should have(1).item}
      end

    end
  end

  describe "#get_or_create_from_wat!" do
    subject {Grouping.get_or_create_from_wat!(wat)}
    it "creates" do
      expect {subject}.to change {Grouping.count}.by 1
    end

    context "with different environments" do
      before do
        Wat.create_from_exception!(error, metadata)
        Wat.create_from_exception!(error, metadata)
        Wat.create_from_exception!(error, {app_env: 'staging'})
      end

      it "groups by app_env" do
        subject.app_envs.should =~ ['production', 'staging']
      end
    end
    context "with a javascript wat" do
      let(:wat) { Wat.create_from_exception!(nil, {language: "javascript"}) {raise RuntimeError.new 'hi'} }
      its(:message) { should == 'hi' }
    end
  end

  describe "#open?" do
    subject {grouping}

    context "with an active wat" do
      let(:grouping) {groupings(:grouping1)}
      it {should be_open}
    end
    context "with a wontfix wat" do
      let(:grouping) {groupings(:wontfix)}
      it {should be_open}
    end
    context "with a resolved wat" do
      let(:grouping) {groupings(:resolved)}
      it {should_not be_open}
    end
    context "with a muffled wat" do
      let(:grouping) {groupings(:muffled)}
      it {should be_open}
    end
  end

  describe "#wat_order" do
    subject {Grouping.wat_order}

    it "should be sorted in-order" do
      pending
      subject.to_a.should == Grouping.all.sort {|x, y| x.wats.last.id <=> y.wats.last.id}
    end

    context "#reverse" do
      subject {Grouping.wat_order.reverse}
      it "should be sorted in-order" do
        subject.to_a.should == Grouping.all.sort {|x, y| y.wats.last.id <=> x.wats.last.id}
      end
    end
  end

  describe "#popularity_addin" do
    let(:grouping) {groupings(:grouping1)}
    let(:effective_time) {Time.zone.now}
    subject { grouping.popularity_addin(effective_time) }

    it "should be positive" do
      subject.should be > 0
    end
  end

  describe "#update_sorting" do
    let(:grouping) {groupings(:grouping1)}
    let(:effective_time) {Time.zone.now}
    subject { grouping.update_sorting(effective_time) }

    it "should change the popularity score" do
      expect { subject }.to change {grouping.popularity}
    end

    it "should update the latest_wat_at" do
      expect { subject }.to change {grouping.latest_wat_at}.to effective_time
    end
  end
end
