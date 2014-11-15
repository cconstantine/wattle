require 'spec_helper'

describe GroupingNoteNotifier do
  let(:grouping_notifier) {GroupingNoteNotifier.new(grouping)}
  let(:grouping) {groupings(:grouping1)}

  describe "#perform" do
    before { stub(grouping_notifier).needs_notifying? {true} }
    subject { grouping_notifier.perform }


    context "on a grouping that never notified" do
      before { grouping.update_column(:last_emailed_at, nil)}
      context "When multiple workers run at the same time" do
        it "should only call send_email once when a new wat is created" do
          call_count = 0

          any_instance_of(GroupingNoteNotifier) do |klass|
            stub(klass).send_email { call_count += 1 }
            stub(klass).send_email_later
          end

          # Call .perform in 3 separate threads (like you would with 3 separate sidekiq workers)
          threads = Set.new
          3.times do |i|
            threads << Thread.new do
              GroupingNoteNotifier.notify(grouping.id)
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
      end
      context "when the grouping is active" do
        let(:grouping) {groupings(:grouping1)}
        it {should be_needs_notifying}
      end
    end
  end

  describe "#email_recipients" do
    subject {grouping_notifier.email_recipients}

    context "for a grouping with no unsubscribes or owners or matching filters" do
      before {Watcher.update_all(email_filters: nil)}

      it {should =~ Watcher.active.to_a}
      it {should_not include(watchers(:inactive))}
    end


    context "for a grouping with unsubscribes" do
      let(:unsubscribed_watcher) {watchers(:another_watcher)}
      before do
        grouping.unsubscribes << unsubscribed_watcher
      end

      it {should include(watchers(:default))}
      it {should_not include(watchers(:inactive))}
      it {should_not include(unsubscribed_watcher)}
    end

    context "for a grouping not matching a watcher's email filters" do
      let(:watcher_with_email_filters) {watchers(:watcher_with_email_filters)}

      it {should_not include(watcher_with_email_filters)}
      it {should include(watchers(:default))}
    end

    context "for a grouping not matching a watcher's email filters" do
      let(:watcher_with_email_filters) {watchers(:watcher_with_email_filters)}

      before do
        watcher_with_email_filters.update_attributes(
          email_filters: {"app_name"=>["app1"], "app_env"=>["production"], "language"=>["ruby"]}.with_indifferent_access
        )
      end

      it {should include(watcher_with_email_filters)}
      it {should include(watchers(:default))}
    end

    context "for a grouping with an owner" do
      let(:grouping) {groupings(:claimed)}

      it {should == [watchers(:with_owned_grouping)]}
    end
  end

  describe "#send_email", sidekiq: :inline do
    subject {grouping_notifier.send_email}


    it "should send emails" do
      subject

      find_email("test@example.com", with_text: "note has been added").should be_present
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
