require 'spec_helper'

feature "Interacting with wats", js: true do

  context "logged in" do
    before do
      visit "/auth/developer"

      fill_in 'name', :with => 'Jim Bob'
      fill_in 'email', :with => 'user@example.com'
      click_on 'Sign In'
    end

    scenario "shows an exception on the homepage" do
      visit "/"
      page.should have_content "RuntimeError"
    end

    context "viewing a wat" do
      before do
        visit "/"
        first(".incident_heading").click
      end

      scenario "clicking on the header takes you to the exception" do
        page.should have_content "a test"
      end

      scenario "leaving a note" do
        within ".new_note" do
          fill_in "note_message", :with => "a testy note"
          click_on "Post"
        end
        within ".note" do
          page.should have_content "Jim Bob"
          page.should have_content "a testy note"
        end
      end

      scenario "acknowledging" do
        within ".states" do
          click_on "Acknowledge"
        end
        within ".current_state" do
          page.should have_content "Acknowledged"
        end
      end

      scenario "resolving" do
        within ".states" do
          click_on "Resolve"
        end
        within ".current_state" do
          page.should have_content "Resolved"
        end
      end

      scenario "reactivating" do
        within ".states" do
          click_on "Resolve"
          click_on "Reactivate"
        end

        within ".current_state" do
          page.should have_content "Active"
        end

      end



    end
  end

end
