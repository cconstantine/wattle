require 'spec_helper'

describe Grouping do

  let(:error) { capture_error {raise RuntimeError.new "test message"} }

  let(:message) {error.message}
  let(:error_class) {error.class.to_s}
  let(:backtrace) { error.backtrace }
  let(:app_env) { 'production' }
  let(:metadata) { { app_env: app_env, language: :ruby } }

  let(:wat) {Wat.new_from_exception(error, metadata) }


  describe ".by_user" do
    subject {Grouping.by_user(user_id)}

    let(:user_id) {"2"}
    it {is_expected.to have(1).item}
  end

  describe "#new_wats" do
    let(:grouping) {groupings(:grouping1)}
    subject {grouping.new_wats}
    context "with a nil last_emailed_at" do
      before { grouping.update_column(:last_emailed_at, nil)}
      it { should have(5).items }
    end
    context "with a last_emailed_at between the latest and 2nd to lastest wat" do
      before {grouping.update_column(:last_emailed_at, grouping.wats.order('id desc').limit(1).last.created_at)}
      it {should have(1).item}
    end
    context "with a last_emailed_at before the latest wat" do
      before {grouping.update_column(:last_emailed_at, grouping.wats.minimum(:created_at) - 1.second)}
      it {is_expected.to have(5).items}
    end

  end

  describe "#unsubscribed?" do
    let(:grouping) {groupings(:grouping1)}
    let(:watcher) {watchers(:default)}
    subject {grouping.unsubscribed?(watcher)}

    it {is_expected.to be_falsey}

    context "with a grouping_unsubscribe record" do
      before {watcher.grouping_unsubscribes.create!(grouping: grouping)}
      it {is_expected.to be_truthy}
    end
  end

  describe "#app_user_stats" do
    subject {grouping.app_user_stats()}
    context "with no app_user info" do
      let(:grouping) {groupings(:grouping1)}
      it {is_expected.to eq( {nil => 5})}
    end

    context "with some interesting app_user info" do
      let(:grouping) {groupings(:grouping4)}
      it {is_expected.to eq( {nil => 2, "2" => 2, "1" => 1})}
    end
  end

  describe "#app_user_count" do
    subject {grouping.app_user_count()}
    context "with no app_user info" do
      let(:grouping) {groupings(:grouping1)}
      it {is_expected.to eq 0}
    end

    context "with some interesting app_user info" do
      let(:grouping) {groupings(:grouping4)}
      it {is_expected.to eq 2}
    end
  end

  describe "#browser_stats" do
    subject {grouping.browser_stats()}
    context "with no browser info" do
      let(:grouping) {groupings(:grouping1)}
      it {is_expected.to eq( {nil => 5})}
    end

    context "with some interesting browser info" do
      let(:grouping) {groupings(:grouping4)}
      it {is_expected.to eq( {nil => 2, "FooBrowser" => 2, "Barser" => 1})}
    end
  end

  describe "#browser_count" do
    subject {grouping.browser_count()}
    context "with no browser info" do
      let(:grouping) {groupings(:grouping1)}
      it {is_expected.to eq 0}
    end

    context "with some interesting browser info" do
      let(:grouping) {groupings(:grouping4)}
      it {is_expected.to eq 2}
    end
  end

  describe "#host_stats" do
    subject {grouping.host_stats()}
    context "with no host info" do
      let(:grouping) {groupings(:grouping4)}
      it {is_expected.to eq( {nil => 5})}
    end

    context "with some interesting browser info" do
      let(:grouping) {groupings(:grouping1)}
      it {is_expected.to eq( {"host1" => 5})}
    end
  end

  describe "#host_count" do
    subject {grouping.host_count()}
    context "with no host info" do
      let(:grouping) {groupings(:grouping4)}
      it {is_expected.to eq 0}
    end

    context "with some interesting browser info" do
      let(:grouping) {groupings(:grouping1)}
      it {is_expected.to eq 1}
    end
  end

  describe "#filtered_by_params" do
    let(:filter_params) { {} }
    let(:filter_opts) { {} }

    let(:scope) {Grouping.state(:unacknowledged)}

    subject {scope.filtered_by_params(filter_params, filter_opts)}

    it {is_expected.to have(scope.count).items}

    context "specifying the state" do
      let(:filter_opts) { { state: :acknowledged }}
      it {is_expected.to have(Grouping.state(:acknowledged).count).items}
    end

    context "specifying the app_env" do
      let(:filter_params) { { app_env: :demo }}
      it {is_expected.to have(scope.app_env(:demo).count).items}
    end
    context "specifying the app_name" do
      let(:filter_params) { { app_name: :app1 }}
      it {is_expected.to have(scope.app_name(:app1).count).items}
    end
    context "specifying the language" do
      let(:filter_params) { { language: :javascript }}
      it {is_expected.to have(scope.language(:javascript).count).items}
    end
    context "specifying the hostname" do
      let(:filter_params) { { hostname: :host2 }}
      it {is_expected.to have(scope.by_host(:host2).count).items}
    end
    context "specifying the user" do
      let(:filter_params) { { app_user: '2' }}
      it {is_expected.to have(scope.by_user('2').count).items}
    end
  end

  describe "#filtered" do
    let(:filter_params) {{}}
    let(:scope) {Grouping.all}
    subject {scope.filtered(filter_params)}
    it {is_expected.to have(Grouping.count).items}

    context "with an app_user" do
      let(:filter_params) {{app_user: "2"}}
      it {is_expected.to have(1).items}
    end

    context "with an app_name" do
      let(:filter_params) {{app_name: "app1"}}
      it {is_expected.to have(5).items}
    end

    context "with an app_env" do
      let(:filter_params) {{app_env: "demo"}}
      it {is_expected.to have(Grouping.open.app_env(:demo).count).items}
    end

    context "with an app_name and an app_env" do
      let(:filter_params) {{app_name: "app2", app_env: "production"}}
      it {is_expected.to have(Grouping.open.app_name(:app2).app_env("production").count).items}
    end

    context "with a hostname" do
      let(:filter_params) {{hostname: ["host1", "host2"]}}
      it {is_expected.to have(2).items}
    end
  end

  describe "#get_or_create_from_wat!" do
    subject {Grouping.get_or_create_from_wat!(wat)}
    it "creates" do
      expect {subject}.to change {Grouping.count}.by 1
    end

    context "with different environments" do
      before do
        Wat.create_from_exception!(error, metadata)
        Wat.create_from_exception!(error, metadata)
        Wat.create_from_exception!(error, {app_env: 'staging'})
      end

      it "groups by app_env" do
        expect(subject.app_envs).to match_array ['production', 'staging']
      end
    end
    context "with a javascript wat" do
      let(:wat) { Wat.create_from_exception!(nil, {language: "javascript"}) {raise RuntimeError.new 'hi'} }
      it {expect(subject.message).to eq 'hi' }
    end
  end

  describe "#open?" do
    subject {grouping}

    context "with an unacknowledged wat" do
      let(:grouping) {groupings(:grouping1)}
      it {is_expected.to be_open}
    end
    context "with a deprioritized wat" do
      let(:grouping) {groupings(:deprioritized)}
      it {is_expected.to be_open}
    end
    context "with a resolved wat" do
      let(:grouping) {groupings(:resolved)}
      it {is_expected.to_not be_open}
    end
    context "with a acknowledged wat" do
      let(:grouping) {groupings(:acknowledged)}
      it {is_expected.to be_open}
    end
  end

  describe "#wat_order" do
    subject {Grouping.wat_order.to_a}

    it "should be sorted in-order" do
     is_expected.to eq Grouping.all.sort {|x, y| x.wats.last.id <=> y.wats.last.id}
    end

    context "#reverse" do
      subject {Grouping.wat_order.reverse.to_a}
      it "should be sorted in-order" do
        is_expected.to eq Grouping.all.sort {|x, y| y.wats.last.id <=> x.wats.last.id}
      end
    end
  end


  describe "#email_recipients" do
    let(:grouping) {groupings(:grouping1)}
    subject {grouping.email_recipients}

    context "for a grouping with no unsubscribes or owners or matching filters" do
      before {Watcher.update_all(email_filters: nil)}

      it {is_expected.to match_array Watcher.active.to_a}
      it {is_expected.to_not include(watchers(:inactive))}
    end


    context "for a grouping with unsubscribes" do
      let(:unsubscribed_watcher) {watchers(:another_watcher)}
      before do
        grouping.unsubscribes << unsubscribed_watcher
      end

      it {is_expected.to include(watchers(:default))}
      it {is_expected.to_not include(watchers(:inactive))}
      it {is_expected.to_not include(unsubscribed_watcher)}
    end

    context "for a grouping not matching a watcher's email filters" do
      let(:watcher_with_email_filters) {watchers(:watcher_with_email_filters)}

      it {is_expected.to_not include(watcher_with_email_filters)}
      it {is_expected.to include(watchers(:default))}
    end

    context "for a grouping not matching a watcher's email filters" do
      let(:watcher_with_email_filters) {watchers(:watcher_with_email_filters)}

      before do
        watcher_with_email_filters.update_attributes(
          email_filters: {"app_name"=>["app1"], "app_env"=>["production"], "language"=>["ruby"]}.with_indifferent_access
        )
      end

      it {is_expected.to include(watcher_with_email_filters)}
      it {is_expected.to include(watchers(:default))}
    end

    context "for a grouping with an owner" do
      let(:grouping) {groupings(:claimed)}

      it {is_expected.to eq [watchers(:with_owned_grouping)]}
    end
  end

  describe "#update_sorting" do
    let(:grouping) {groupings(:grouping1)}
    let(:effective_time) {Time.zone.now}
    subject { grouping.update_sorting(effective_time) }

    it "should update the latest_wat_at" do
      expect { subject }.to change {grouping.latest_wat_at}.to effective_time
    end
  end

  describe "reindex on state change" do
    let(:grouping) { groupings(:grouping1) }
    subject { grouping.resolve! }

    it "should do a reindexing" do
      allow(grouping).to receive(:reindex)
      subject
      expect(grouping).to have_received(:reindex)
    end
  end

  describe "#search_data" do
    let(:grouping) {groupings(:grouping1)}
    subject { grouping.search_data }

    it "should have the right keys" do
      expect(subject.keys).to match_array([
          :key_line,
          :error_class,
          :state,
          :message,
          :app_name,
          :app_env,
          :language,
          :user_emails,
          :hostname,
          :user_ids,
          :latest_wat_at])
    end

    context "with a long message" do
      before {grouping.wats.last.update!(message: "I'm a long message!  " * 32767 )}
      it "should trim the message" do
        expect(subject[:message].count).to_not be_blank

        subject[:message].each do |x|
          expect(x.length).to be <= 32766
        end
      end
    end
  end

  describe "#tracker_story_name" do
    let(:grouping) { groupings(:grouping1) }

    subject { grouping.tracker_story_name }

    it "returns the approriate values for the tracker story name" do
      expect(subject).to include grouping.id.to_s
      expect(subject).to include grouping.app_user_count.to_s
      expect(subject).to include grouping.wats.size.to_s
    end

    context "if there is only an error_class of the error" do
      before { grouping.update! error_class: "SomeErrorClass", message: nil }

      it { is_expected.to include grouping.error_class }
    end

    context "if there is only a message of the error" do
      before { grouping.update! error_class: nil, message: "some error message" }

      it { is_expected.to include grouping.message }
    end
  end

  describe "#resolve!" do
    let(:grouping) { groupings(:grouping1) }

    subject { grouping.resolve! }

    it "changes the grouping state" do
      expect{subject}.to change{grouping.state}.from("unacknowledged").to("resolved")
    end

    context "if there is an associated tracker story" do
      let(:tracker_id) { "some-tracker-id" }
      let(:tracker_stub) { double(:tracker_client) }
      let(:story_stub) { double(:story) }

      before { grouping.update! pivotal_tracker_story_id: tracker_id }

      it "accepts the story and adds a note" do
        expect(grouping).to receive(:accept_tracker_story).and_call_original
        expect_any_instance_of(Tracker).to receive(:client) { tracker_stub }
        expect(tracker_stub).to receive(:story).with(tracker_id).and_return(story_stub)
        expect(story_stub).to receive(:current_state)
        expect(story_stub).to receive(:current_state=).with("accepted")
        expect(story_stub).to receive(:save)
        subject
      end

      it "gracefully handles errors raised by Tracker" do
        expect(grouping).to receive(:accept_tracker_story).and_call_original
        expect_any_instance_of(Tracker).to receive(:client) { tracker_stub }
        allow(tracker_stub).to receive(:story).with(tracker_id).and_raise("oh noes!")

        expect { subject }.not_to raise_error
      end
    end
  end

  describe ".retrieve_stale_groupings" do
    let(:acknowledged_grouping) { groupings :acknowledged }
    let(:resolved_grouping) { groupings :resolved }
    let(:time_frame) { 5.days.ago }

    subject { described_class.retrieve_stale_groupings(time_frame) }

    before do
      acknowledged_grouping.update! latest_wat_at: 10.days.ago
      resolved_grouping.update! latest_wat_at: 10.days.ago
    end

    it "should retrieve acknowledged wats after the given time frame" do
      expect(subject).to include acknowledged_grouping
      expect(subject).not_to include resolved_grouping
    end
  end
end
