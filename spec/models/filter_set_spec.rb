require 'spec_helper'

describe FilterSet do
  let(:filter_set) { FilterSet.new(filters) }

  describe "#filters" do
    subject { filter_set.filters }

    context "filters exist" do
      let(:filters) { {"foo" => "bar"} }

      it { should == filters }
    end

    context "filters don't exist" do
      let(:filters) { nil }

      it { should == FilterSet::DEFAULT_FILTERS }
    end
  end

  describe "#checked?" do
    let(:filters) { {"foo" => "bar"} }

    subject { filter_set.checked?(key, value) }

    context "when the key exists" do
      let(:key) { "foo" }

      context "when the value is in the key's list" do
        let(:value) { "bar" }

        it { should == true }
      end

      context "when the value isn't in the key's list" do
        let(:value) { "pizza" }

        it { should == false }
      end
    end

    context "when the key doesn't exist" do
      let(:key) { "not a key" }
      let(:value) { "why_even_care" }

      it { should == false }
    end
  end
end
