require "spec_helper"

feature "Interacting with groupings", js: true do
  before do
    visit root_path

    fill_in "name", with: "Jim Bob"
    fill_in "email", with: "user@example.com"
    click_on "Sign In"
  end

  it "lists groupings on the homepage" do
    visit root_path
    expect(page).to have_content "FakeFixtureError"
  end

  describe "filtering them via the sidebar" do
    it "removes the unchecked categories of groupings when you check something" do
      visit root_path

      expect(page).to have_content "a ruby exception"
      expect(page).to have_content "a javascript exception"

      within(".page_filters") do
        expect(page.find(:checkbox, "ruby")).to_not be_checked
        check "ruby"
      end

      expect(page).to have_content "a ruby exception"
      expect(page).to_not have_content "a javascript exception"
    end
  end

  context "viewing an individual grouping" do
    let(:grouping) { groupings(:grouping1) }

    before do
      visit grouping_path(grouping, filters: {
        "state" => {"active" => "1", "resolved" => "1", "wontfix" => "1", "muffled" => "1"}
      })
    end

    it "shows you the exception class and message" do
      expect(page).to have_content "FakeFixtureError"
      expect(page).to have_content "a test"
    end

    it "let you leave a note" do
      within ".new_note" do
        fill_in "note_message", with: "a testy note"
        click_on "Post"
      end
      within ".note" do
        expect(page).to have_content "Jim Bob"
        expect(page).to have_content "a testy note"
      end
    end

    it "lets you mark the grouping as won't fix" do
      within ".states" do
        click_on "Won't Fix"
      end
      within ".current_state" do
        expect(page).to have_content "Wontfix"
      end
    end

    it "lets you mark the grouping as muffled" do
      within ".states" do
        click_on "Muffle"
      end
      within ".current_state" do
        expect(page).to have_content "Muffled"
      end
    end

    it "lets you mark the grouping as resolved" do
      within ".states" do
        click_on "Resolve"
      end
      within ".current_state" do
        expect(page).to have_content "Resolved"
      end
    end

    context "with a resolved grouping" do
      let(:grouping) { groupings(:resolved) }

      it "lets you reactivate the grouping" do
        within ".states" do
          click_on "Reactivate"
        end

        within ".current_state" do
          expect(page).to have_content "Active"
        end
      end
    end
  end
end
