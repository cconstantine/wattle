require 'spec_helper'

describe TokenSource do
  let(:source) { TokenSource.new }
  
  describe "#generate" do
    subject { source.generate }

    it "generates a 40 character token" do
      expect(subject.length).to eq(40)
    end

    it "contains only letters and numbers" do
      expect(subject).not_to match(/\W/)
    end

    it "is different each time" do
      expect(subject).not_to eq(source.generate)
      expect(subject).not_to eq(source.generate)
    end
  end
end

