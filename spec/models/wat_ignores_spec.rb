require 'spec_helper'

describe WatIgnores do
  describe "#matches?" do
    let(:wat) {wats(:default)}
    subject {WatIgnores.matches?(wat)}
    context "without any records" do
      it { should be_falsey }
    end

    context "with a user_agent" do
      let(:wat) {wats(:with_user_agent)}

      context "without any records" do
        it { should be_falsey }
      end

      context "with non-matching records" do
        it { should be_falsey }
      end

      context "with a matching record" do
        let!(:matching_record) {WatIgnores.create!(user_agent: "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/27.0.1453.110 Safari/537.36")}
        it { should be_truthy }
      end
    end
  end
end
