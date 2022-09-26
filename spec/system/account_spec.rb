# frozen_string_literal: true

require "spec_helper"

describe "Account", type: :system do
  let(:user) { create(:user, :confirmed, password: password, password_confirmation: password, organization: organization) }
  let(:password) { "dqCFgjfDbC7dPbrv" }
  let!(:organization) { create(:organization) }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
  end

  describe "navigation" do
    it "shows the account form when clicking on the menu" do
      visit decidim.root_path

      within_user_menu do
        first("a", text: "Profile", visible: false).click
      end

      expect(page).to have_css("form.edit_user")
    end

    context "when clicking on the menu" do
      context "and user is author" do
        before do
          allow(user).to receive(:signataire?).and_return(false)
        end

        it "user author sees link to initiatives" do
          visit decidim.root_path

          within_user_menu do
            find("a", text: "MY INITIATIVES").click
          end

          expect(current_url).to include "/initiatives?filter%5Bauthor%5D=myself"
        end
      end

      context "and user is signataire" do
        before do
          allow(user).to receive(:signataire?).and_return(true)
        end

        it "user doesn't see link to initiatives" do
          visit decidim.root_path

          within_user_menu do
            expect(page).not_to have_content("MY INITIATIVES")
          end
        end
      end
    end
  end

  context "when on the account page" do
    before do
      visit decidim.account_path
    end

    it "displays authorizations link" do
      expect(page).to have_content("Authorizations")
    end

    context "when accessing authorizations" do
      let!(:organization) do
        create(:organization, available_authorizations: authorizations)
      end

      let(:authorizations) { %w(france_connect_uid france_connect_profile osp_authorization_handler) }

      it "displays FC authorizations" do
        click_link "Authorizations"
        expect(page).to have_content("Identification FranceConnect comme Signataire")
        expect(page).to have_content("Identification FranceConnect comme Auteur")
        expect(page).to have_no_content("OSP Authorization handler")
        expect(page).to have_css("h5.card--list__heading", count: 2)
      end
    end

    describe "updating personal data" do
      it "updates the user's data" do
        within "form.edit_user" do
          expect(page).to have_field("user_name", readonly: true)

          fill_in :user_email, with: "nikola.tesla@example.org"

          perform_enqueued_jobs { find("*[type=submit]").click }
        end

        within_flash_messages do
          expect(page).to have_content("successfully")
        end

        within ".title-bar" do
          expect(page).to have_content(user.name)
        end

        user.reload

        within_user_menu do
          first("a", text: "Profile", visible: false).click
        end

        expect(find("#user_email").value).to eq(user.email)
        expect(last_email.subject).to include("Instructions de confirmation")
      end

      context "when on the delete account modal" do
        it "the user can delete his account" do
          find("input.open-modal-button[type=\"submit\"]").click
          fill_in :delete_account_delete_reason, with: "I just want to delete my account"
          click_button "Yes, I want to delete my account"
          within_flash_messages do
            expect(page).to have_content("successfully")
          end
        end
      end
    end

    context "when on the notifications settings page" do
      before do
        visit decidim.notifications_settings_path
      end

      it "updates the user's notifications" do
        within ".switch.newsletter_notifications" do
          page.find(".switch-paddle").click
        end

        within "form.edit_user" do
          find("*[type=submit]").click
        end

        within_flash_messages do
          expect(page).to have_content("successfully")
        end
      end
    end
  end
end
