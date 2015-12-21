require 'spec_helper'

describe GroupingNotifier do
  let(:grouping) {groupings(:grouping1)}
  let(:grouping_notifier) { GroupingNotifier.new.tap {|gn| gn.grouping = grouping} }

  describe "#perform" do
    let(:grouping_notifier) { GroupingNotifier.new }

    before { allow_any_instance_of(GroupingNotifier).to receive(:needs_notifying?) {true} }

    subject { grouping_notifier.perform(grouping.id) }

    context "on a grouping that never notified" do
      before { grouping.update_column(:last_emailed_at, nil)}

      context "When multiple workers run at the same time" do

        it "should only call send_email once" do
          call_count = 0

          allow(grouping_notifier).to receive(:send_email) {call_count += 1}

          subject
          expect(call_count).to eq(1)
        end

      end
    end

    context "needs_notifying?? is true" do
      before { allow(grouping_notifier).to receive(:needs_notifying?) {true} }

      it "should send_email" do
        allow(grouping_notifier).to receive(:send_email)
        subject
        expect(grouping_notifier).to have_received(:send_email)
      end
    end

    context "send_email is false" do
      before {allow(grouping_notifier).to receive(:needs_notifying?) {false}}

      it "should not send_email" do
        allow(grouping_notifier).to receive(:send_email)
        subject
        expect(grouping_notifier).to_not have_received(:send_email)
      end

    end
  end

  describe "#needs_notifying?" do
    subject {grouping_notifier}

    context "with a sidekiq job" do
      let(:retry_option) {true}
      let(:grouping) {Wat.create_from_exception!(nil, {app_name: :app1, app_env: 'production', sidekiq_msg: {"retry"=>retry_option, "retry_count" => 5, "queue"=>"default", "class"=>"FailedWorker", "args"=>[], "jid"=>"7f3849342188a8b17456ab33", "enqueued_at"=>enqueued_at.to_f.to_s}}) {raise "Something"}.grouping}

      context "the retry option is nil" do
        let(:enqueued_at) { Time.now }
        let(:retry_option) {nil}
        it { is_expected.to be_needs_notifying }
      end

      context "the retry option is 0" do
        let(:enqueued_at) { Time.now }
        let(:retry_option) {0}
        it { is_expected.to be_needs_notifying }
      end

      context "the retry option is false" do
        let(:enqueued_at) { Time.now }
        let(:retry_option) {false}
        it { is_expected.to be_needs_notifying }
      end

      context "grouping's wat is too recent" do
        let(:enqueued_at) { Time.now }
        it { is_expected.to_not be_needs_notifying }
      end

      context "grouping's wat is old enough" do
        let(:enqueued_at) { 800.seconds.ago}
        it { is_expected.to be_needs_notifying }
      end

      context "with a specified notify_after" do
        let(:grouping) {Wat.create_from_exception!(nil, {app_name: :app1, app_env: 'production', sidekiq_msg: {"retry"=>true, "retry_count" => 5, "queue"=>"default", "notify_after"=>"700", "class"=>"FailedWorker", "args"=>[], "jid"=>"7f3849342188a8b17456ab33", "enqueued_at"=>enqueued_at.to_f.to_s}}) {raise "Something"}.grouping}

        context "grouping's wat is too recent" do
          let(:enqueued_at) { Time.now }
          it { is_expected.to_not be_needs_notifying }
        end

        context "grouping's wat is old enough" do
          let(:enqueued_at) { 800.seconds.ago}
          it { is_expected.to be_needs_notifying }
        end
      end
    end

    context "with a blank last_emailed_at" do
      before { grouping.update_column :last_emailed_at, nil }
      context "when the grouping is resolved" do
        let(:grouping) {groupings(:resolved)}
        it {is_expected.to_not be_needs_notifying}
      end
      context "when the grouping is deprioritized" do
        let(:grouping) {groupings(:deprioritized)}
        it {is_expected.to_not be_needs_notifying}
      end
      context "when the grouping is acknowledged" do
        let(:grouping) {groupings(:acknowledged)}

        context "with 1000 wats per hour in the last weeks" do
          before { allow(grouping_notifier).to receive(:similar_wats_per_hour_in_previous_weeks) { 1000 } }
          context "with 1000 wats in the last day" do
            before { allow(grouping_notifier).to receive(:similar_wats_in_previous_day) { 1000 } }

            it {is_expected.to_not be_needs_notifying}
          end

          context "with 2000 wats in the last hour" do
            before { allow(grouping_notifier).to receive(:similar_wats_in_previous_day) { 2000 } }

            it {is_expected.to be_needs_notifying}
          end
        end
      end
      context "when the grouping is unacknowledged" do
        let(:grouping) {groupings(:grouping1)}
        it {is_expected.to be_needs_notifying}

        context "with a js grouping" do
          before { allow(grouping).to receive(:is_javascript?) { true } }

          context "with an average of 1000 wats per hour in the last 24 hours" do
            before { allow(grouping_notifier).to receive(:js_wats_per_hour_in_previous_weeks) { 1000 } }

            context "with 2000 wats in the last hour" do
              before { allow(grouping_notifier).to receive(:js_wats_in_previous_day) { 2000 } }

              it {is_expected.to be_needs_notifying}
            end
            context "with 1000 wats in the last hour" do
              before { allow(grouping_notifier).to receive(:js_wats_in_previous_day) { 1000 } }

              it {is_expected.to_not be_needs_notifying}
            end
          end
        end
      end
    end
  end

  describe "#similar_wats_per_hour_in_previous_weeks" do
    subject { grouping_notifier.similar_wats_per_hour_in_previous_weeks }

    it { is_expected.to eq 2 }
  end
  describe "#similar_wats_in_previous_day" do
    subject { grouping_notifier.similar_wats_in_previous_day }

    it { is_expected.to eq 53 }
  end


  describe "#send_email", sidekiq: :inline do
    subject {grouping_notifier.send_email}


    it "should send emails" do
      subject

      expect(find_email("test@example.com", with_text: "been detected in")).to be_present
    end


    it "should not send emails to watchers with restrictive email_filters" do
      subject
      expect(find_email("test3@example.com", with_text: "been detected in")).to_not be_present
    end
  end

  describe "#send_email_now?" do
    before { allow(grouping_notifier).to receive(:needs_notifying?) {true} }
    subject {grouping_notifier.send_email_now?}
    context "when the grouping was never notified" do
      before { grouping.update_column(:last_emailed_at, nil)}
      it {is_expected.to be_truthy}
    end
    context "when the grouping was notified recently" do
      before { grouping.update_column(:last_emailed_at, 1.minute.ago)}
      it {is_expected.to be_falsey}
    end
    context "when the grouping was not notified recently" do
      before { grouping.update_column(:last_emailed_at, 1.day.ago)}
      it {is_expected.to be_truthy}
      context "with a deprioritized grouping" do
        let(:grouping) {groupings(:deprioritized)}

        it {is_expected.to be_falsey}
      end
    end
  end

  it_behaves_like "the debounce enqueue method"
end
