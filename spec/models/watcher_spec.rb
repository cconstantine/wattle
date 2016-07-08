require 'spec_helper'

describe Watcher do

  describe "#create" do
    subject {Watcher.create!(first_name: "Bob", name: "bob?", email: "bob@example.com")}

    it {should be_present}
    it {expect(subject.state).to eq "active"}
  end

  describe ".activate" do
    let(:watcher) { watchers(:default) }
    subject {watcher.activate; watcher}

    it {should be_active}
    context "when inactive" do
      let(:watcher) {watchers(:inactive)}
      it "should change to active" do
        expect {subject}.to change {watcher.state}.to "active"
      end
    end
  end


  describe ".deactivate" do
    let(:watcher) { watchers(:inactive) }
    subject {watcher.deactivate; watcher}

    it {should be_inactive}

    context "when active" do
      let(:watcher) {watchers(:default)}
      it "should change to inactive" do
        expect {subject}.to change {watcher.state}.to "inactive"
      end
    end
  end


  describe "#find_or_create_from_auth_hash" do
    subject do
      Watcher.find_or_create_from_auth_hash! auth_data
    end
    context "when a matching user exists" do
      let(:auth_data) {{ email: "test@example.com" }}
      it "should find the Watcher and not create one" do
        expect { subject }.not_to change(Watcher, :count)
        expect(subject).to eq watchers(:default)
      end
    end
    context "when no matching user exists" do
      let(:auth_data) {{ email: "fake1@example.com", first_name: "Edward" }}
      it "should make a new Watcher" do
        expect { subject }.to change(Watcher, :count)

        expect(subject).to eq Watcher.last
        expect(Watcher.last.email).to eq "fake1@example.com"
        expect(Watcher.last.first_name).to eq "Edward"
      end
    end
    context "when creating a non @example.com user" do
      let(:auth_data) {{email: "mallory@scoobilydoo.com", first_name: "Mallory"}}
      it "should refuse to make the watcher" do
        expect { subject }.to raise_error ActiveRecord::RecordInvalid
      end
    end
  end

  describe ".retrieve_system_account" do
    subject { described_class.retrieve_system_account }

    context "if the account does not exist" do
      it "should create the system account" do
        expect{ subject }.to change{ Watcher.count }.by(1)
      end
    end

    context "if the account exists" do
      before { subject }

      it "should retrieve the system account" do
        expect{ subject }.not_to change{ Watcher.count }
        expect(subject).not_to be_nil
      end
    end
  end
end
