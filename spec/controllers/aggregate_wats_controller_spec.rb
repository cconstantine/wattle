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

    it "should have the right data" do
      aggregate_data = JSON.parse subject.body
      expect(aggregate_data.first.keys).to match_array(['app_env', 'app_name', 'period', 'count', 'period_length', 'language'])
    end

    context "when the request is daily" do
      before do
        future_wat.update_column :created_at, 1.day.from_now
      end
      it "should return an array of json counts" do
        aggregate_data = JSON.parse subject.body
        demo_row = aggregate_data.find { |d| d['app_env'] == 'demo' && d['language'] == 'ruby' }
        expect(aggregate_data.first['count']).to eq(1)
        expect(demo_row['count']).to eq(5)
      end
    end

    context "when the request is paginated" do
      subject { get :periodic, scale: timescale, per_page: '2', format: :json }
      it "returns the correct number of rows" do
        aggregate_data = JSON.parse subject.body
        expect(aggregate_data).to have(2).rows
      end 

      context "and a second page is requested" do
        subject { get :periodic, scale: timescale, page: '2', per_page: '2', format: :json }
        it "sends different data" do
          first_page = JSON.parse(get(:periodic, scale: timescale, per_page: '2', format: :json).body)
          second_page = JSON.parse subject.body
          expect(first_page).not_to eq(second_page)
        end
      end
    end

  end

end

