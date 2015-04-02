require 'spec_helper'

describe WatCounter do
  let(:counter) { WatCounter.new scale }
  let(:scale) { 'day' }

  describe "#wats" do
    let!(:wat_creation_timestamp) { wats(:default).created_at }
    let(:future_wat) { Wat.create_from_exception!(nil, {app_env: :production}) { raise "time is trouble" } }
    subject { counter.wats }

    def db_time(time)
      Time.utc(time.year, time.month, time.day, time.hour)
    end

    context "by day" do
      before do
        future_wat.update_column :created_at, 1.day.from_now
      end

      it "returns segmented daily data" do
        data = subject.count
        expect(data[db_time(1.day.from_now.beginning_of_day)]).to eq(1)
        expect(data[db_time(wat_creation_timestamp.beginning_of_day)]).to eq(69)
      end
    end
    context "by hour" do
      let(:scale) { 'hour' }
      before do
        future_wat.update_column :created_at, 1.hour.from_now
      end

      it "returns segmented hourly data" do
        data = subject.count
        expect(data[db_time(1.hour.from_now)]).to eq(1)
        expect(data[db_time(wat_creation_timestamp)]).to eq(69)
      end
    end
    context "by week" do
      let(:scale) { 'week' }
      before do
        future_wat.update_column :created_at, 1.week.from_now
      end

      it "returns segmented weekly data" do
        data = subject.count
        expect(data[db_time(1.week.from_now.beginning_of_week)]).to eq(1)
        expect(data[db_time(wat_creation_timestamp.beginning_of_week)]).to eq(69)
      end
    end
    context "by month" do
      let(:scale) { 'month' }
      before do
        future_wat.update_column :created_at, 1.month.from_now
      end

      it "returns segmented monthly data" do
        data = subject.count
        expect(data[db_time(1.month.from_now.beginning_of_month)]).to eq(1)
        expect(data[db_time(wat_creation_timestamp.beginning_of_month)]).to eq(69)
      end
    end
  end
  describe "#group" do
    it "adds to the counters groupings" do
      counter.group(:app_env)
      expect(counter.send :groupings).to include(:app_env)
    end
    it "groups the wats" do
      data = counter.group(:app_env).count.to_a
      first_key, second_key, _ = *data.map(&:first)
      expect(first_key[1]).to eq("demo")
      expect(second_key[1]).to eq("production")
    end
  end

  describe "#format" do
    let(:wats) { counter.wats }
    subject { counter.format wats }
    it "returns a hash" do
      expect(subject.first.keys).to match_array(%i[ period period_length count ])
    end

    context "when the counter has additional groups" do
      let(:wats) { counter.group(:app_env) }
      it "adds a key for the groups" do
        expect(subject.first.keys).to match_array(%i[ period period_length count app_env ])
      end
    end

  end
end
