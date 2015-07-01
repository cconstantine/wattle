require "spec_helper"

shared_examples_for "the debounce enqueue method" do

  let(:klass) { described_class }
  let!(:grouping) {groupings(:grouping1)}

  before do
    allow(klass).to receive(:perform_async)
    allow(klass).to receive(:perform_in)
  end

  context "being called in quick succession" do

    subject do
      threads = Set.new
      10.times do |i|
        threads << Thread.new do
          klass.debounce_enqueue(grouping.id, klass::DEBOUNCE_DELAY)
        end
      end
      threads.each do |thread|
        thread.join
      end
    end

    it "should enqueue the first one" do
      subject
      expect(klass).to have_received(:perform_async).with(grouping.id)
    end

    it "should delay the 2nd" do

      subject
      expect(klass).to have_received(:perform_in).with(anything, anything)
    end
  end
end
