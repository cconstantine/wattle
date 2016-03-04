require 'spec_helper'

feature "Creating a Tracker story for a grouping" do

  context "as a user with an API key" do
    before do
      visit "/auth/developer"

      fill_in "name", :with => "Jim Bob"
      fill_in "email", :with => "tracker_test@example.com"
      click_on "Sign In"
    end

    it "creates a story" do
      visit grouping_path(groupings(:grouping1))

      expect(page).to_not have_content "Add your Tracker API key to create stories with the click of a button"
      expect(page).to have_content "Create a story"

      select("Testy Project", from: "Create a story")
      click_on "Create Tracker story"

      visit grouping_path(groupings(:grouping1))

      expect(page).to have_content "View this wat's Pivotal Tracker story"
    end
  end

  context "as a user without an API key" do
    before do
      visit "/auth/developer"

      fill_in "name", :with => "Jim Bob"
      fill_in "email", :with => "user@example.com"
      click_on "Sign In"
    end

    it "doesn't show the tracker thingy" do
      visit grouping_path(groupings(:grouping1))
      expect(page).to have_content "Add your Tracker API key"
      expect(page).to_not have_content "Create a story"
    end
  end
end
