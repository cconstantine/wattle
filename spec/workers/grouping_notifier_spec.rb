require 'spec_helper'

describe GroupingNotifier do
  let(:grouping_notifier) {GroupingNotifier.new(grouping)}
  let(:grouping) {groupings(:grouping1)}

  describe "#perform" do
    subject { grouping_notifier.perform }

    context "send_email_now? is true" do
      before {stub(grouping_notifier).send_email_now? {true}}
      it "should send_email" do
        stub.proxy(grouping_notifier).send_email
        stub.proxy(grouping_notifier).send_email_later
        subject
        expect(grouping_notifier).to have_received(:send_email)
        expect(grouping_notifier).to_not have_received(:send_email_later)
      end
    end
    context "send_email is false" do
      before {stub(grouping_notifier).send_email_now? {false}}
      it "should not send_email" do
        stub.proxy(grouping_notifier).send_email
        stub.proxy(grouping_notifier).send_email_later
        subject
        expect(grouping_notifier).to_not have_received(:send_email)
        expect(grouping_notifier).to have_received(:send_email_later)
      end

      context "and the grouping is acknowledged" do
        let(:grouping) {groupings(:acknowledged)}
        it "should not send_email" do
          stub.proxy(grouping_notifier).send_email
          stub.proxy(grouping_notifier).send_email_later
          subject
          expect(grouping_notifier).to_not have_received(:send_email)
          expect(grouping_notifier).to_not have_received(:send_email_later)
        end
      end
    end
  end

  describe "#send_email_now?" do
    subject {grouping_notifier.send_email_now?}
    context "when the grouping was never notified" do
      before { grouping.update_column(:last_emailed_at, nil)}
      it {should be_true}
    end
    context "when the grouping was notified recently" do
      before { grouping.update_column(:last_emailed_at, 1.minute.ago)}
      it {should be_false}
    end
    context "when the grouping was not notified recently" do
      before { grouping.update_column(:last_emailed_at, 1.day.ago)}
      it {should be_true}
      context "with an acknowledged grouping" do
        let(:grouping) {groupings(:acknowledged)}

        it {should be_false}
      end
    end
  end
end