require "spec_helper"

describe "Filtering the wat groupings" do
  before do
    visit "/auth/developer"

    fill_in "name", :with => "Jim Bob"
    fill_in "email", :with => "user@example.com"
    click_on "Sign In"
  end

  it "lets a user save a default set of filters" do
    visit root_path

    within ".watcher_default_fields" do
      expect(page.find(:checkbox, "ruby")).to be_checked
      uncheck "ruby"
      expect(page.find(:checkbox, "ruby")).to_not be_checked

      expect(page.find(:checkbox, "Resolved")).to_not be_checked
      check "Resolved"
      expect(page.find(:checkbox, "Resolved")).to be_checked
    end

    click_button "Save as Defaults"

    expect(page).to have_content "Your defaults were saved!"


    visit root_path

    within ".page_filters" do
      expect(page.find(:checkbox, "ruby")).to_not be_checked
      expect(page.find(:checkbox, "Resolved")).to be_checked
    end
  end
end
