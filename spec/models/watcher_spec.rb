require 'spec_helper'

describe Watcher do
  describe "#find_or_create_from_auth_hash" do
    subject do
      Watcher.find_or_create_from_auth_hash auth_data
    end
    context "when a matching user exists" do
      let(:auth_data) {{ email: "test@example.com" }}
      it "should find the Watcher and not create one" do
        expect { subject }.not_to change(Watcher, :count)
        subject.should == watchers(:default)
      end
    end
    context "when no matching user exists" do
      let(:auth_data) {{ email: "fake@example.com", first_name: "Edward" }}
      it "should make a new Watcher" do
        expect { subject }.to change(Watcher, :count)
        subject.should == Watcher.last
        Watcher.last.email.should == "fake@example.com"
        Watcher.last.first_name.should == "Edward"
      end

    end
    context "when the hash is bad" do
      let(:auth_data) { nil }
      it "should raise an error" do
        expect { subject }.to raise_error
      end
    end
  end
end
