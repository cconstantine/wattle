require 'spec_helper'

feature "Claiming ownership of groupings", js: true do

  context "logged in" do
    before do
      visit "/auth/developer"

      fill_in 'name', :with => 'Jim Bob'
      fill_in 'email', :with => 'user@example.com'
      click_on 'Sign In'
    end

    context "viewing a grouping" do
      before do
        visit grouping_path(grouping, filters: {state: ["active", "resolved", "wontfix", "muffled"]})
      end
      context "with a grouping you own" do
        let(:grouping) {groupings(:grouping1)}
        before {click_on "Claim"}

        context "when clicking Unclaim" do
          subject { click_on "Unclaim" }

          it "should remove you from the list of owners" do
            page.find(".owners").should have_content("Jim Bob")
            subject
            page.find(".owners").should_not have_content("Jim Bob")
          end
        end
      end
      context "with a grouping claimed by someone else" do
        let(:grouping) {groupings(:claimed)}

        it "should already have an owner" do
          page.find(".owners").should have_content('Owning Watcher')
        end

        context "when clicking claim" do
          subject { click_on "Claim" }

          scenario "should make you an owner" do
            subject

            page.find(".owners").should have_content('Jim Bob')
          end

          scenario "should only send emails to the owners" do
            subject

            GroupingNotifier.new(grouping).send_email
            find_email("test@example.com",  with_text: "been detected in").should_not be_present
            find_email("test5@example.com", with_text: "been detected in").should be_present
            find_email("user@example.com",  with_text: "been detected in").should be_present
          end
        end
      end
      context "with an unclaimed grouping" do
        let(:grouping) {groupings(:grouping1)}
        context "when clicking claim" do
          subject { click_on "Claim" }

          scenario "should make you the owner" do
            subject

            page.find(".owners").should have_content('Jim Bob')
          end

          scenario "should tell you that no one else will get emails" do
            subject
            page.should have_content "won't receive emails"
          end

          scenario "should only send emails to you" do
            subject

            GroupingNotifier.new(grouping).send_email

            find_email("test@example.com", with_text: "been detected in").should_not be_present
            find_email("user@example.com", with_text: "been detected in").should be_present
          end

          scenario "should present the ability to unclaim" do
            subject
            page.should have_content "Unclaim"
          end
        end
      end
    end
  end
end
