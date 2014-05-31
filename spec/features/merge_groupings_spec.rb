require 'spec_helper'

feature "Merging groupings", js: true do
  let(:child1) { groupings(:grouping1) }
  let(:child2) { groupings(:grouping2) }
  let(:child_groupings) { [child1, child2] }
  let(:new_grouping) { Grouping.last }

  context "logged in" do
    before do
      visit "/auth/developer"

      fill_in 'name', :with => 'Jim Bob'
      fill_in 'email', :with => 'user@example.com'
      click_on 'Sign In'
    end

    it "shows the groupings on the index page pre-merge" do
      expect(page).to have_content child1.representative_wat.message
      expect(page).to have_content child2.representative_wat.message
    end

    describe "merging groupings" do
      before do
        visit new_grouping_path
        fill_in "grouping_ids", with: "#{child1.id}, #{child2.id}"
        click_button "Create Grouping"
      end

      it "shows the new grouping" do
        expect(page).to have_content "Daily Stats" # Show page
        expect(page).to have_content Grouping.last.representative_wat.message
      end

      it "no longer shows the merged groupings on the index page" do
        visit groupings_path
        expect(page).to have_css("a[href='#{grouping_path(Grouping.last)}']")
        expect(page).not_to have_css("a[href='#{grouping_path(child1)}']")
        expect(page).not_to have_css("a[href='#{grouping_path(child2)}']")
      end
    end
  end
end
