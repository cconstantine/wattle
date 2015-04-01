require 'spec_helper'

describe AggregateWatsController, type: :controller do
  let(:watcher) { watchers(:default) }

  describe "#periodic" do
    subject { get :periodic, scale: timescale, format: :json }
    let(:timescale) { 'day' }
    let(:future_wat) { Wat.create_from_exception!(nil, {app_env: :production}) { raise "time is trouble" } }

    before do
      login watcher
    end

    context "when the request is daily" do
      before do
        future_wat.update_column :created_at, 1.day.from_now
      end
      it "should return an array of json counts" do
        daily_data = JSON.parse subject.body
        expect(daily_data.values.first).to eq(1)
        expect(daily_data.values.second).to eq(69)
      end
    end

    context "when the request is hourly" do
      let(:timescale) { 'hour' }
      before do
        future_wat.update_column :created_at, 1.hour.from_now
      end
      it "should return an array of json counts" do
        daily_data = JSON.parse subject.body
        expect(daily_data.values.first).to eq(1)
        expect(daily_data.values.second).to eq(69)
      end
    end

    context "when the request is weekly" do
      let(:timescale) { 'week' }
      before do
        future_wat.update_column :created_at, 1.week.from_now
      end
      it "should return an array of json counts" do
        daily_data = JSON.parse subject.body
        expect(daily_data.values.first).to eq(1)
        expect(daily_data.values.second).to eq(69)
      end
    end

    context "when the request is monthly" do
      let(:timescale) { 'month' }
      before do
        future_wat.update_column :created_at, 1.month.from_now
      end
      it "should return an array of json counts" do
        daily_data = JSON.parse subject.body
        expect(daily_data.values.first).to eq(1)
        expect(daily_data.values.second).to eq(69)
      end
    end
  end

end

