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
      wg.should_not be_empty

      subject
      wg.each do |x|
        expect {x.reload}.to raise_error ActiveRecord::RecordNotFound
      end
    end

    it "removes the grouping if we are the last wat" do
      groupings = wat.groupings.to_a
      subject
      groupings.should_not be_empty

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

    its(:session) {should == {"derpy" => "\\u0000"}}
    its(:request_headers) {should == {"HTTP_ACCEPT" => "\\u0000"}}
    its(:request_params) {should == {"nulls" => "\\u0000"}}
    its(:backtrace) {should == ["bob", "\\u0000"]}
    its(:app_user) {should == {"derpy" => "\\u0000"}}

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
  end

  describe "clean_hstore" do
    context "with a hash" do
      subject {Wat.new.clean_hstore(hash)}
      context "that is normal" do
        let(:hash) { {a: 1, b: "laksjdf"} }
        it {should == hash}
      end

      context "with a null value" do
        let(:hash)  { {a: "\u0000", b: 1} }
        it {should == {a: "\\u0000", b: 1}}
      end

      context "with a null key" do
        let(:hash)  { {"\u0000" => "a", :b => 1} }
        it {should == {"\\u0000" => "a", :b => 1}}
      end
    end

    context "with an array" do
      subject {Wat.new.clean_hstore(array)}
      context "that is normal" do
        let(:array) {[1, 2, "bob"]}
        it {should == array}
      end

      context "with a null value" do
        let(:array)  { ["\u0000", 1] }
        it {should == ["\\u0000", 1] }
      end

    end
  end
  describe "matching_selector" do
    let(:wat) { wats(:default) }
    subject { wat.matching_selector }
    its(:keys) {should =~ [:key_line, :error_class]}

    context "with a javascript wat" do
      let(:wat) {wats(:javascript)}
      its(:keys) { should =~ [:message] }
    end
  end

  describe "after_commit" do
    let(:wat) { Wat.new_from_exception {raise RuntimeError.new 'hi'} }

    subject {wat.save!}
    it "should call the notify the wat notifier" do
      Sidekiq::Testing.inline! do

        stub.proxy(GroupingNotifier).notify
        subject

        expect(GroupingNotifier).to have_received(:notify).with wat.groupings.active.last.id
          # Some other tests
      end
    end

    it "should call send_email" do
      stub.proxy(wat).send_email
      subject

      expect(wat).to have_received(:send_email)
    end

    it "should upvote the groupings" do
      stub.proxy(wat).upvote_groupings
      subject
      expect(wat).to have_received(:upvote_groupings)
    end
  end

  describe "#upvote_groupings" do
    let(:wat) { wats(:default) }
    subject { wat.upvote_groupings }
    it "should upvote all of the open groupings" do
      expect { subject}.to change {wat.groupings.open.first.popularity}
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

    context "with a state" do
      let(:filter_params) {{state: :wontfix}}
      it {should have(5).item}
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
      its(:message)     { should == "test message"}
      its(:error_class) { should == "RuntimeError"}
      its(:app_env)     { should == "production"}
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
      let!(:grouping) {Grouping.where(key_line: wat.key_line, error_class: wat.error_class).first_or_create!}

      it "should not create a grouping" do
        expect {subject}.not_to change {Grouping.count}
      end

      it "should bind to the existing grouping" do
        subject
        wat.groupings.should include(grouping)
      end
      context "a javascript exception" do
        let(:wat) {wats(:javascript)}
        let(:grouping) { wat.groupings.first }
        it "should bind to the existing grouping" do
          subject
          wat.groupings.should include(grouping)
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
          wat.groupings.should include(existing_wat.groupings.first)
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
        wat.groupings.should include(grouping)
      end
    end
    context "with an existing wontfix duplicate error" do
      let!(:grouping) { Grouping.where(key_line: wat.key_line, error_class: wat.error_class).first_or_create!.tap {|g| g.wontfix!} }

      it "should create a grouping" do
        expect {subject}.to change {Grouping.count}.by 0
      end

      it "should bind to the existing grouping" do
        subject
        wat.groupings.should include(grouping)
      end
    end
  end


end
