require 'spec_helper'

describe DailyGroupingUpdater do
  subject { described_class.new }

  describe "#perform" do
    let(:acknowledged_grouping) { groupings :acknowledged }
    let(:resolved_grouping) { groupings :resolved }
    let(:app_name) { :app1 }

    context "more than 15 days after the latest wat" do
      before do
        acknowledged_grouping.update! latest_wat_at: 20.days.ago
        resolved_grouping.update! latest_wat_at: 20.days.ago
      end

      it "should resolve the acknowledged wats of a given app and set the system account" do
        expect {
          subject.perform(app_name: app_name)
        }.to change {GroupingVersion.count}.by 1
        expect(GroupingVersion.last.whodunnit).to eq Watcher.retrieve_system_account.id.to_s
      end

      it "should not resolve the acknowledged wats of a different app" do
        expect_any_instance_of(Grouping).not_to receive(:resolve!)
        subject.perform(app_name: "non-existent-app")
      end
    end

    context "with a specific time frame passed in" do
      let(:time_frame) { 5.days.ago }

      before do
        acknowledged_grouping.update! latest_wat_at: 10.days.ago
        resolved_grouping.update! latest_wat_at: 10.days.ago
      end

      it "should resolve the acknowledged wats of a given app and set the system account" do
        expect {
          subject.perform(app_name: app_name, time_frame: time_frame)
        }.to change {GroupingVersion.count}.by 1
        expect(GroupingVersion.last.whodunnit).to eq Watcher.retrieve_system_account.id.to_s
      end
    end
  end
end
