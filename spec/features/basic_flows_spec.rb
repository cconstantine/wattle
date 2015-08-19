require 'spec_helper'

feature "Interacting with wats", js: true, :type => :feature do


  context "with an invalid email" do
    it "should give an error" do
      visit "/"

      fill_in 'name', :with => 'Jim Bob'
      fill_in 'email', :with => 'user@not_valid_domain.com'
      click_on 'Sign In'
      expect(page).to have_content "Unable to find or create user"
    end
  end

  context "when going to a grouping directly" do
    let(:grouping) {groupings(:grouping1)}
    scenario "redirects you back to that grouping after logging in" do
      visit grouping_path(grouping)

      fill_in 'name', :with => 'Jim Bob'
      fill_in 'email', :with => 'user@example.com'
      click_on 'Sign In'

      expect(current_path).to eq grouping_path(grouping)
    end
  end

  context "logged in" do
    before do
      visit "/auth/developer"

      fill_in 'name', :with => 'Jim Bob'
      fill_in 'email', :with => 'user@example.com'
      click_on 'Sign In'
    end

    scenario "shows a wat on the homepage" do
      visit "/"
      expect(page).to have_content "RuntimeError"
    end

    scenario "lets you log out" do
      click_on "Jim Bob"
      click_on "Logout"
      expect(page).to have_content "Sign In"
    end

    context "viewing a grouping" do
      let(:grouping) {groupings(:grouping1)}
      before do
        visit grouping_path(grouping, filters: {state: ["unacknowledged", "resolved", "deprioritized", "acknowledged"]})
      end

      scenario "clicking on the header takes you to the exception" do
        expect(page).to have_content "a test"
      end

      scenario "leaving a note" do
        within ".new_note" do
          fill_in "note_message", :with => "a testy note"
          click_on "Post"
        end
        within ".stream-event" do
          expect(page).to have_content "Jim Bob"
          expect(page).to have_content "a testy note"
        end
      end

      context "with a note" do
        let!(:note)  { grouping.notes.create!(watcher: note_author, message: "some note") }

        context "written by the logged in user" do
          let(:note_author) { Watcher.last }

          scenario "destroying a note" do
            visit grouping_path(grouping, filters: {state: ["unacknowledged", "resolved", "deprioritized", "acknowledged"]})

            within "#note_#{note.id}" do
              expect(page).to have_content "Jim Bob"
              expect(page).to have_content "some note"

              first('.delete').click
            end

            expect(page).to_not have_content "some note"
          end

        end
        context "written by someone else" do
          let(:note_author) { watchers(:another_watcher) }

          scenario "someone else's note isn't deletable" do
            visit grouping_path(grouping, filters: {state: ["unacknowledged", "resolved", "deprioritized", "acknowledged"]})

            within "#note_#{note.id}" do
              expect(page).to have_content note_author.name
              expect(page).to have_content "some note"

              expect(page).to_not have_css(".delete")
            end
          end
        end
      end

      scenario "deprioritizing" do
        within ".states" do
          click_on "Deprioritize"
        end
        within ".current_state" do
          expect(page).to have_content "Deprioritized"
        end
      end

      scenario "acknowledging" do
        within ".states" do
          click_on "Acknowledge"
        end
        within ".current_state" do
          expect(page).to have_content "Acknowledged"
        end
      end

      scenario "resolving" do
        within ".states" do
          click_on "Resolve"
        end
        within ".current_state" do
          expect(page).to have_content "Resolved"
        end
      end

      context "with a resolved grouping" do
        let(:grouping) {groupings(:resolved)}

        scenario "unresolving" do
          within ".states" do
            click_on "Unresolve"
          end

          within ".current_state" do
            expect(page).to have_content "Acknowledged"
          end
        end
      end
    end
  end
end
