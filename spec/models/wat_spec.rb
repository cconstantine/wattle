require 'spec_helper'

describe Wat do

  describe ".by_user" do
    subject {Wat.by_user(user_id)}

    let(:user_id) {"2"}
    it {should have(2).items}
  end

  describe "#destroy" do
    let(:wat) {wats(:default)}
    subject {wat.destroy}

    it "it should go away" do
      subject
      expect {wat.reload}.to raise_error ActiveRecord::RecordNotFound
    end

    it "removes the associated wat grouping" do
      wg = wat.wats_groupings.to_a
      expect(wg).to_not be_empty

      subject
      wg.each do |x|
        expect {x.reload}.to raise_error ActiveRecord::RecordNotFound
      end
    end

    it "removes the grouping if we are the last wat" do
      groupings = wat.groupings.to_a
      subject
      expect(groupings).to_not be_empty

      subject
      groupings.each do |x|
        expect {x.reload}.to raise_error ActiveRecord::RecordNotFound
      end
    end
  end

  describe "#create" do
    let(:wat) do
      Wat.create!(
        "session" => {
          "derpy" => "\u0000"
        },
        "request_headers" => {
          "HTTP_ACCEPT" => "\u0000",
        },
        "request_params" => {
          "nulls" => "\u0000",
        },
        "backtrace" => [
          "bob",
          "\u0000"
        ],
        "app_user" => {
          "derpy" => "\u0000"
        }
      )
    end

    subject {wat}

    it "should create" do
      expect { subject }.to change {Wat.count}.by 1
    end

    it {expect(subject.session).to eq( {"derpy" => "\\u0000"})}
    it {expect(subject.request_headers).to eq({"HTTP_ACCEPT" => "\\u0000"})}
    it {expect(subject.request_params).to eq({"nulls" => "\\u0000"})}
    it {expect(subject.backtrace).to eq ["bob", "\\u0000"]}
    it {expect(subject.app_user).to eq({"derpy" => "\\u0000"})}

    context "with a crazy-long language" do
      let(:wat) {Wat.create!(:language => "visual basic")}

      it "should throw a record invalid error" do
        expect {subject}.to raise_error ActiveRecord::RecordInvalid
      end
    end
    context "with an ignored user_agent" do
      before {WatIgnores.create!(user_agent: "IGNOREME")}

      let(:wat) {Wat.create!(
        "request_headers" => {
          "HTTP_USER_AGENT" => "IGNOREME",
        })}


      it "should throw a record invalid error" do
        expect {subject}.to raise_error ActiveRecord::RecordInvalid
      end
    end

    context "when multiple creates! are called at the same time" do
      let(:concurrency) {16}
      subject do
        threads = Set.new
        concurrency.times do |i|
          threads << Thread.new do
            wat = Wat.new_from_exception(nil, {app_env: 'testy-test'}) {raise "a test #{i}"}
            begin
              wat.save!
            rescue ActiveRecord::RecordNotUnique
              wat.save!
            end
          end
        end

        # and wait for them to finish executing
        threads.each do |thread|
          thread.join
        end
      end


      it "should only create one grouping" do
        expect {subject}.to change(Grouping, :count).by 1
      end

      it "should only create three wats" do
        expect {subject}.to change(Wat, :count).by concurrency
      end

    end
  end

  describe "clean_hstore" do
    context "with a hash" do
      subject {Wat.new.clean_hstore(hash)}
      context "that is normal" do
        let(:hash) { {a: 1, b: "laksjdf"} }
        it {is_expected.to eq hash}
      end

      context "with a null value" do
        let(:hash)  { {a: "\u0000", b: 1} }
        it {is_expected.to eq( {a: "\\u0000", b: 1})}
      end

      context "with a null key" do
        let(:hash)  { {"\u0000" => "a", :b => 1} }
        it {is_expected.to eq({"\\u0000" => "a", :b => 1})}
      end
    end

    context "with an array" do
      subject {Wat.new.clean_hstore(array)}
      context "that is normal" do
        let(:array) {[1, 2, "bob"]}
        it {is_expected.to eq array}
      end

      context "with a null value" do
        let(:array)  { ["\u0000", 1] }
        it {is_expected.to eq ["\\u0000", 1] }
      end

    end
  end
  describe "matching_selector" do
    let(:wat) { wats(:default) }
    subject { wat.matching_selector }

    it {expect(subject.keys).to match_array [:key_line, :error_class]}

    context "with a javascript wat" do
      let(:wat) {wats(:javascript)}
      it {expect(subject.keys).to eq [:message] }
    end
  end


  describe "uniqueness_string" do
    let(:grouping) { groupings(:grouping1)}
    let(:wats) { grouping.wats }
    subject { wats.map &:uniqueness_string }

    context "on a single wat" do
      subject {wats.first.uniqueness_string}
      it {is_expected.to be_a String}
    end

    it "should have the same uniqueness_strings" do
      expect(subject.uniq).to have(1).item
    end

    describe "between groupings" do
      let(:grouping1) {groupings(:grouping1)}
      let(:grouping2) {groupings(:grouping2)}

      let(:grouping1_uniqueness) {grouping1.wats.first.uniqueness_string}
      let(:grouping2_uniqueness) {grouping2.wats.first.uniqueness_string}

      it "should have different uniqueness_strings" do
        expect(grouping1_uniqueness).to_not eq grouping2_uniqueness
      end
    end

    context "with a javascript wat" do
      let(:grouping) { groupings(:normal_javascripts)}

      it "should have the same uniqueness_strings" do
        expect(subject.uniq).to have(1).item
      end
    end
  end

  describe "after_commit" do
    let(:wat) { Wat.new_from_exception {raise RuntimeError.new 'hi'} }

    subject {wat.save!}
    it "should call the debounce_enqueue method from the wat notifier" do
      Sidekiq::Testing.inline! do

        allow(GroupingNotifier).to receive(:debounce_enqueue) {  }
        subject

        expect(GroupingNotifier).to have_received(:debounce_enqueue).with wat.groupings.unacknowledged.last.id, GroupingNotifier::DEBOUNCE_DELAY
      end
    end

    it "should call send_email" do
      allow(wat).to receive(:send_email) {  }
      subject

      expect(wat).to have_received(:send_email)
    end

    it "should upvote the groupings" do
      allow(wat).to receive(:upvote_groupings) {  }
      subject
      expect(wat).to have_received(:upvote_groupings)
    end
  end

  describe "#backtrace" do
    it "can have a very long path" do
      bt = (1..1000).map { |x| "#{x} long string"*1000 }

      wats(:default).update_attributes(backtrace: bt)
    end
  end

  describe "#filtered" do
    let(:filter_params) {{}}
    let(:scope) {Wat.all}
    subject {scope.filtered(filter_params)}
    it {should have(Wat.count).items}


    context "with an app_user" do
      let(:filter_params) {{app_user: "2"}}
      it {should have(2).items}
    end

    context "with an app_name" do
      let(:filter_params) {{app_name: "app1"}}
      it {should have(Wat.where(app_name: :app1).count).items}
    end

    context "with an app_env" do
      let(:filter_params) {{app_env: "demo"}}
      it {should have(Wat.where(app_env: :demo).count).items}
    end

    context "with an app_name and an app_env" do
      let(:filter_params) {{app_name: "app2", app_env: "production"}}
      it {should have(Wat.where(app_name: :app2, app_env: "production").count).items}
    end

    context "with a hostname" do
      let(:filter_params) {{hostname: :host1}}
      it {should have(5).item}
      context "with more than one hostname" do
        let(:filter_params) {{hostname: [:host1, :host2]}}
        it {should have(10).item}
      end
    end
  end

  describe "#create!" do
    let(:error) { capture_error {raise RuntimeError.new "test message"} }

    let(:message) {error.message}
    let(:error_class) {error.class.to_s}
    let(:backtrace) { error.backtrace }
    let(:app_env) { "production" }

    subject {Wat.create!(message: error.message, error_class: error.class.to_s, backtrace: error.backtrace, app_env: app_env)}
    it { should == Wat.last }

    describe "#create_from_exception" do
      subject { Wat.create_from_exception!(error, {app_env: app_env} )}

      it                { should == Wat.last }
      it {expect(subject.message).to eq "test message"}
      it {expect(subject.error_class).to eq  "RuntimeError"}
      it {expect(subject.app_env).to eq  "production"}

      it "should create a new wat" do
        expect {subject}.to change {Wat.count}.by(1)
      end
    end
  end

  describe "#user_agent" do
    subject {wat.user_agent}
    context "without any user_agent available" do
      let(:wat) {wats(:default)}
      it {should be_nil}
    end
    context "with an HTTP_USER_AGENT header" do
      let(:wat) {wats(:with_user_agent)}
      it {should be_instance_of Agent}
    end
  end

  describe "#key_line" do
    subject {wat.key_line}
    let(:wat) { wats(:default)}

    it {should match /spec/ }

    context "with an exception from a gem" do
      let(:error) {capture_error {Wat.create!(:not_a_field => 1)} }
      it {should match /spec/ }
    end
  end

  describe "construct_groupings!" do
    let(:wat) { wats(:default)}
    subject { wat.construct_groupings! }

    context "with a brand new wat" do
      let(:wat) { Wat.new_from_exception {raise RuntimeError.new 'hi'} }

      it "should create a Grouping" do
        expect {subject}.to change {Grouping.count}.by 1
      end
    end

    context "with an existing duplicate error" do
      let!(:grouping) {Grouping.where(key_line: wat.key_line, error_class: wat.error_class).first_or_create!(uniqueness_string: "laksdjlskjslkjsdlk")}

      it "should not create a grouping" do
        expect {subject}.not_to change {Grouping.count}
      end

      it "should bind to the existing grouping" do
        subject
        expect(wat.groupings).to include(grouping)
      end
      context "a javascript exception" do
        let(:wat) {wats(:javascript)}
        let(:grouping) { wat.groupings.first }
        it "should bind to the existing grouping" do
          subject
          expect(wat.groupings).to include(grouping)
        end

      end

      context "when the line contains a release timestamp" do
        let(:existing_wat) { wats(:default) }
        let(:wat) do
          existing_wat.dup.tap do |w|
            original_key_line = w.key_line
            new_key_line = w.key_line.gsub(/(#{Rails.root})/, '\1/releases/20130330231716')
            w.backtrace.map! { |l| l == original_key_line ? new_key_line : l }
            w.save!
          end
        end

        before do
          existing_wat.construct_groupings!
        end

        it "should bind to the existing grouping" do
          subject
          expect(wat.groupings).to include(existing_wat.groupings.first)
        end

      end
    end

    context "with an existing resolved duplicate error" do
      let!(:grouping) { Grouping.where(key_line: wat.key_line, error_class: wat.error_class).first_or_create!.tap {|g| g.resolve!} }

      it "should create a grouping" do
        expect {subject}.to change {Grouping.count}.by 1
      end

      it "should not bind to the existing grouping" do
        subject
        expect(wat.groupings).to include(grouping)
      end
    end

    context "with an existing deprioritized duplicate error" do
      let!(:grouping) { Grouping.where(key_line: wat.key_line, error_class: wat.error_class).first_or_create!.tap {|g| g.deprioritize!} }

      it "should create a grouping" do
        expect {subject}.to change {Grouping.count}.by 0
      end

      it "should bind to the existing grouping" do
        subject
        expect(wat.groupings).to include(grouping)
      end
    end
  end

  describe "#validate_sidekiq_job_retry_count" do
    let(:final_sidekiq_msg) { sidekiq_msg }
    let(:wat) { Wat.new sidekiq_msg: final_sidekiq_msg }

    subject { wat.validate_sidekiq_job_retry_count }

    context "with a job that retries" do
      let(:sidekiq_msg) {{
        "jid" => "ac839153b79a152ecb9d2a0b",
        "args" => "[23061]",
        "class" => "RiskScreenerLeadUploader",
        "queue" => "medium",
        "retry" => true,
        "enqueued_at" => "1427155937.2241511"
      }}

      context "with no retry count" do
        it "adds an error" do
          subject
          expect(wat).to have(1).errors_on :sidekiq_msg
        end
      end

      context "with a retry count of 1" do
        let(:final_sidekiq_msg) { sidekiq_msg.merge({"retry_count" => "1" }) }

        it "adds an error" do
          subject
          expect(wat).to have(1).errors_on :sidekiq_msg
        end
      end

      context "with a retry count of 4" do
        let(:final_sidekiq_msg) { sidekiq_msg.merge({"retry_count" => "4" }) }

        it "doesn't an error" do
          subject
          expect(wat).to have(0).errors_on :sidekiq_msg
        end
      end
    end

    context "with a job that doesn't retry" do
      let(:sidekiq_msg) {{
        "jid" => "ac839153b79a152ecb9d2a0b",
        "args" => "[23061]",
        "class" => "RiskScreenerLeadUploader",
        "queue" => "medium",
        "retry" => false,
        "enqueued_at" => "1427155937.2241511"
      }}

      it "doesn't add an error" do
        subject
        expect(wat).to have(0).errors_on :sidekiq_msg
      end
    end
  end
end
