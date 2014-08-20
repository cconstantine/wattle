require "spec_helper"

feature "Logging in" do
  context "with an invalid email address" do
    it "does not create a user & shows an error" do
      visit root_path

      fill_in "name", with: "Jim Bob"
      fill_in "email", with: "this is not a valid email address"
      click_on "Sign In"
      expect(page).to have_content "Unable to find or create user"
    end
  end

  context "with a valid email address" do
    it "creates a user & redirects you back to your original page" do
      grouping = groupings(:grouping1)
      visit grouping_path(grouping)

      fill_in "name", with: "Jim Bob"
      fill_in "email", with: "user@example.com"
      click_on "Sign In"

      current_path.should == grouping_path(grouping)
    end
  end
end
