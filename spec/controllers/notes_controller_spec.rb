require 'spec_helper'

describe NotesController do

  describe "#create" do
    let(:grouping) { groupings(:grouping1) }
    let(:the_post) { post :create, grouping_id: grouping.to_param, note: {message: "I'm a message" } }
    before {request.env["HTTP_REFERER"] = "http://example.com/original?place=thing"}

    subject { the_post }

    it "should fail" do
      subject
      response.should_not be_success
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
        response.should redirect_to :back
      end

      context "the created note" do
        subject do
          the_post
          assigns[:note]
        end
        its(:id)       {should_not be_nil}
        its(:watcher)  {should == watcher}
        its(:message)  {should == "I'm a message"}
        its(:grouping) {should == grouping}
      end
    end
  end
end
