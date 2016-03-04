require "spec_helper"

feature "Filtering the wat groupings" do
  before do
    visit "/auth/developer"

    fill_in "name", :with => "Jim Bob"
    fill_in "email", :with => "user@example.com"
    click_on "Sign In"
  end

  it "lets a user save default page filters" do
    visit root_path
    click_on "Jim Bob"
    click_on "Settings"

    within ".watcher_default_filter_fields" do
      expect(page.find(:checkbox, "ruby")).to_not be_checked
      check "ruby"
      expect(page.find(:checkbox, "ruby")).to be_checked
    end

    click_button "Save"

    expect(page).to have_content "Your defaults were saved!"

    visit root_path

    within ".page_filters" do
      expect(page.find(:checkbox, "ruby")).to be_checked
    end

    # Make sure emails go out appropriately when a new wat comes in
    Wat.create_from_exception!(nil, app_name: "app1", app_env: "staging") { raise "hi" }
    expect(find_email("test@example.com", with_text: "been detected in")).to be_present
    expect(find_email("user@example.com", with_text: "been detected in")).to be_present

  end

  it "lets a user save default email filters" do
    visit root_path

    click_on "Jim Bob"
    click_on "Settings"

    within ".watcher_email_filter_fields" do
      expect(page.find(:checkbox, "javascript")).to_not be_checked
      check "javascript"
      expect(page.find(:checkbox, "javascript")).to be_checked
    end

    click_button "Save"

    expect(page).to have_content "Your defaults were saved!"

    within ".watcher_email_filter_fields" do
      expect(page.find(:checkbox, "ruby")).to_not be_checked
      expect(page.find(:checkbox, "javascript")).to be_checked
    end

    # Make sure emails go out appropriately when a new wat comes in
    Wat.create_from_exception!(nil, app_name: "app1", app_env: "staging") { raise "hi" }
    expect(find_email("test@example.com", with_text: "been detected in")).to be_present
    expect(find_email("user@example.com", with_text: "been detected in")).to_not be_present
  end


  it "lets a user save default email and page filters" do
    visit root_path

    click_on "Jim Bob"
    click_on "Settings"

    within ".watcher_default_filter_fields" do
      expect(page.find(:checkbox, "ruby")).to_not be_checked
      check "ruby"
      expect(page.find(:checkbox, "ruby")).to be_checked
    end

    within ".watcher_email_filter_fields" do
      expect(page.find(:checkbox, "javascript")).to_not be_checked
      check "javascript"
      expect(page.find(:checkbox, "javascript")).to be_checked
    end

    click_button "Save"

    expect(page).to have_content "Your defaults were saved!"

    within ".watcher_email_filter_fields" do
      expect(page.find(:checkbox, "ruby")).to_not be_checked
      expect(page.find(:checkbox, "javascript")).to be_checked
    end

    within ".watcher_default_filter_fields" do
      expect(page.find(:checkbox, "ruby")).to be_checked
    end

    # Make sure emails go out appropriately when a new wat comes in
    Wat.create_from_exception!(nil, app_name: "app1", app_env: "staging") { raise "hi" }
    expect(find_email("test@example.com", with_text: "been detected in")).to be_present
    expect(find_email("user@example.com", with_text: "been detected in")).to_not be_present
  end

  it "lets a user save their tracker API key" do
    visit root_path

    click_on "Jim Bob"
    click_on "Settings"

    expect do
      fill_in "watcher[pivotal_tracker_api_key]", with: "cool-api-key"
      click_button "Save"

      click_on "Jim Bob"
      click_on "Settings"
    end.to change { page.find("#watcher_pivotal_tracker_api_key").value }.to "cool-api-key"
  end
end
