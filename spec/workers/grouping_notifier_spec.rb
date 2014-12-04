require 'spec_helper'

describe GroupingNotifier do
  let(:grouping_notifier) {GroupingNotifier.new(grouping)}
  let(:grouping) {groupings(:grouping1)}

  describe "#perform" do
    before { stub(grouping_notifier).needs_notifying? {true} }

    subject { grouping_notifier.perform }


    context "on a grouping that never notified" do
      before { grouping.update_column(:last_emailed_at, nil)}
      context "When multiple workers run at the same time" do
        it "should only call send_email once" do
          call_count = 0

          any_instance_of(GroupingNotifier) do |klass|
            stub(klass).send_email { call_count += 1 }
            stub(klass).send_email_later
          end

          # Call .perform in 3 separate threads (like you would with 3 separate sidekiq workers)
          threads = Set.new
          3.times do |i|
            threads << Thread.new do
              GroupingNotifier.notify(grouping.id)
            end
          end

          # and wait for them to finish executing
          threads.each do |thread|
            thread.join
          end
          expect(call_count).to eq(1)
        end

      end
    end

    context "when the redis semaphore is borked" do
      before do
        Sidekiq::redis do |redis|
          stub(grouping_notifier).semaphore_lock_period {1}
          @semaphore = Redis::Semaphore.new(:GroupingNotifierSemaphore, :connection => redis)
          redis.blpop(@semaphore.send(:available_key), 1)
          expect(@semaphore.available_count).to eq 0
        end
      end

      after do
        @semaphore.delete!
      end

      it "handles a broken semaphore gracefully" do
        expect {grouping_notifier.perform}.to raise_error GroupingNotifier::SemaphoricError
        expect {grouping_notifier.perform}.to_not raise_error
      end
    end


    context "send_email_now? is true" do
      before { stub(grouping_notifier).send_email_now? {true} }
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

    end
  end

  describe "#needs_notifying?" do
    subject {grouping_notifier}

    context "with a sidekiq job" do
      let(:retry_option) {true}
      let(:grouping) {Wat.create_from_exception!(nil, {app_name: :app1, app_env: 'production', sidekiq_msg: {"retry"=>retry_option, "queue"=>"default", "class"=>"FailedWorker", "args"=>[], "jid"=>"7f3849342188a8b17456ab33", "enqueued_at"=>enqueued_at.to_f.to_s}}) {raise "Something"}.groupings.first}

      context "the retry option is nil" do
        let(:enqueued_at) { Time.now }
        let(:retry_option) {nil}
        it { should be_needs_notifying }
      end

      context "the retry option is 0" do
        let(:enqueued_at) { Time.now }
        let(:retry_option) {0}
        it { should be_needs_notifying }
      end

      context "the retry option is false" do
        let(:enqueued_at) { Time.now }
        let(:retry_option) {false}
        it { should be_needs_notifying }
      end

      context "grouping's wat is too recent" do
        let(:enqueued_at) { Time.now }
        it { should_not be_needs_notifying }
      end

      context "grouping's wat is old enough" do
        let(:enqueued_at) { 800.seconds.ago}
        it { should be_needs_notifying }
      end

      context "with a specified notify_after" do
        let(:grouping) {Wat.create_from_exception!(nil, {app_name: :app1, app_env: 'production', sidekiq_msg: {"retry"=>true, "queue"=>"default", "notify_after"=>"700", "class"=>"FailedWorker", "args"=>[], "jid"=>"7f3849342188a8b17456ab33", "enqueued_at"=>enqueued_at.to_f.to_s}}) {raise "Something"}.groupings.first}

        context "grouping's wat is too recent" do
          let(:enqueued_at) { Time.now }
          it { should_not be_needs_notifying }
        end

        context "grouping's wat is old enough" do
          let(:enqueued_at) { 800.seconds.ago}
          it { should be_needs_notifying }
        end
      end
    end

    context "with a blank last_emailed_at" do
      before { grouping.update_column :last_emailed_at, nil }
      context "when the grouping is resolved" do
        let(:grouping) {groupings(:resolved)}
        it {should_not be_needs_notifying}
      end
      context "when the grouping is wontfix" do
        let(:grouping) {groupings(:wontfix)}
        it {should_not be_needs_notifying}
      end
      context "when the grouping is muffled" do
        let(:grouping) {groupings(:muffled)}

        context "with 1000 wats per hour in the last weeks" do
          before { stub(grouping_notifier).similar_wats_per_hour_in_previous_weeks { 1000 } }
          context "with 1000 wats in the last day" do
            before { stub(grouping_notifier).similar_wats_in_previous_day { 1000 } }

            it {should_not be_needs_notifying}
          end

          context "with 2000 wats in the last hour" do
            before { stub(grouping_notifier).similar_wats_in_previous_day { 2000 } }

            it {should be_needs_notifying}
          end
        end
      end
      context "when the grouping is active" do
        let(:grouping) {groupings(:grouping1)}
        it {should be_needs_notifying}

        context "with a js grouping" do
          before { stub(grouping).is_javascript? { true } }

          context "with an average of 1000 wats per hour in the last 24 hours" do
            before { stub(grouping_notifier).js_wats_per_hour_in_previous_weeks { 1000 } }

            context "with 2000 wats in the last hour" do
              before { stub(grouping_notifier).js_wats_in_previous_day { 2000 } }

              it {should be_needs_notifying}
            end
            context "with 1000 wats in the last hour" do
              before { stub(grouping_notifier).js_wats_in_previous_day { 1000 } }

              it {should_not be_needs_notifying}
            end
          end
        end
      end
    end
  end

  describe "#send_email", sidekiq: :inline do
    subject {grouping_notifier.send_email}


    it "should send emails" do
      subject

      find_email("test@example.com", with_text: "been detected in").should be_present
    end


    it "should not send emails to watchers with restrictive email_filters" do
      subject

      find_email("test3@example.com", with_text: "been detected in").should_not be_present
    end
  end

  describe "#send_email_now?" do
    before { stub(grouping_notifier).needs_notifying? {true} }
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
      context "with a wontfix grouping" do
        let(:grouping) {groupings(:wontfix)}

        it {should be_false}
      end
    end
  end
end
