require 'spec_helper'

describe NotesController, :type => :controller do

  describe "#create" do
    let(:grouping) { groupings(:grouping1) }
    let(:the_post) { post :create, grouping_id: grouping.to_param, note: {message: "I'm a message" } }
    before {request.env["HTTP_REFERER"] = "http://example.com/original?place=thing"}

    subject { the_post }

    it "should fail" do
      subject
      expect(response).to_not be_success
    end

    context "when logged in" do
      let(:watcher) { watchers(:default) }
      before do
        login watchers(:default)
      end

      it "should make note" do
        expect {subject}.to change(Note, :count).by 1
      end

      it "should send back to the page we were on" do
        subject
        expect(response).to redirect_to :back
      end

      context "the created note" do
        subject do
          the_post
          assigns[:note]
        end
        it {expect(subject.id).to be_present}
        it {expect(subject.id).to be_present}
        it {expect(subject.watcher).to eq watcher }
        it {expect(subject.message).to eq "I'm a message" }
        it {expect(subject.grouping).to eq grouping }
      end
    end
  end
end
