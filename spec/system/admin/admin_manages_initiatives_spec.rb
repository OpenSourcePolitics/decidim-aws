# frozen_string_literal: true

require "spec_helper"

describe "Admin manages initiatives", type: :system do
  STATES = Decidim::Initiative.states.keys.map(&:to_sym)
                              .reject { |state| state =~ /classified|examinated|debatted/i }

  def create_initiative_with_trait(trait)
    create(:initiative, trait, organization: organization)
  end

  def initiative_with_state(state)
    Decidim::Initiative.find_by(state: state)
  end

  def initiative_without_state(state)
    Decidim::Initiative.where.not(state: state).sample
  end

  def initiative_with_type(type)
    Decidim::Initiative.join(:scoped_type).find_by(decidim_initiatives_types_id: type)
  end

  def initiative_without_type(type)
    Decidim::Initiative.join(:scoped_type).where.not(decidim_initiatives_types_id: type).sample
  end

  def initiative_with_area(area)
    Decidim::Initiative.find_by(decidim_area_id: area)
  end

  def initiative_without_area(area)
    Decidim::Initiative.where.not(decidim_area_id: area).sample
  end

  include_context "with filterable context"

  let(:organization) { create(:organization) }
  let(:user) { create(:user, :admin, :confirmed, organization: organization) }
  let(:model_name) { Decidim::Initiative.model_name }
  let(:type1) { create :initiatives_type, organization: organization }
  let(:type2) { create :initiatives_type, organization: organization }
  let(:scoped_type1) { create :initiatives_type_scope, type: type1 }
  let(:scoped_type2) { create :initiatives_type_scope, type: type2 }
  let(:area1) { create :area, organization: organization }
  let(:area2) { create :area, organization: organization }

  STATES.each do |state|
    let!(:"#{state}_initiative") { create_initiative_with_trait(state) }
  end

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit decidim_admin.root_path
    within ".main-nav" do
      click_link "Initiatives"
    end

    within ".secondary-nav" do
      click_link "Initiatives"
    end
  end

  describe "listing initiatives" do
    shared_examples_for "sort by ID desc" do
      it "displays initiatives in DESC order" do
        expect(find(".sort_link.desc").text).to include("ID")
        expect(find("tbody>tr:first-child>td:first-child").text).to eq(Decidim::Initiative.last.id.to_s)
      end
    end

    context "when listing from main nav" do
      before do
        within ".main-nav" do
          click_link "Initiatives"
        end
      end

      it_behaves_like "sort by ID desc"
    end

    context "when listing from secondary nav" do
      before do
        within ".secondary-nav" do
          click_link "Initiatives"
        end
      end

      it_behaves_like "sort by ID desc"
    end

    STATES.each do |state|
      I18n.locale = :en
      i18n_state = I18n.t(state, scope: "decidim.admin.filters.state_eq.values")

      context "filtering collection by state: #{i18n_state}" do
        it_behaves_like "a filtered collection", options: "State", filter: i18n_state do
          let(:in_filter) { translated(initiative_with_state(state).title) }
          let(:not_in_filter) { translated(initiative_without_state(state).title) }
        end
      end
    end

    it "can be searched by title" do
      search_by_text(translated(published_initiative.title))

      expect(page).to have_content(translated(published_initiative.title))
    end

    Decidim::InitiativesTypeScope.all.each do |scoped_type|
      type = scoped_type.type
      i18n_type = type.title[I18n.locale.to_s]

      context "filtering collection by type: #{i18n_type}" do
        before do
          create(:initiative, organization: organization, scoped_type: scoped_type1)
          create(:initiative, organization: organization, scoped_type: scoped_type2)
        end

        it_behaves_like "a filtered collection", options: "Type", filter: i18n_type do
          let(:in_filter) { translated(initiative_with_type(type).title) }
          let(:not_in_filter) { translated(initiative_without_type(type).title) }
        end
      end
    end

    it "doesn't allow to filter by area" do
      within(".filters__section") do
        find_link("Filter").hover
        expect(page).to have_no_content("Area")
      end
    end

    it "doesn't allow to filter by archive category" do
      within(".filters__section") do
        find_link("Filter").hover
        expect(page).to have_no_content("Archive category")
      end
    end

    it "can be searched by description" do
      search_by_text(translated(published_initiative.description))

      expect(page).to have_content(translated(published_initiative.title))
    end

    it "can be searched by id" do
      search_by_text(published_initiative.id)

      expect(page).to have_content(translated(published_initiative.title))
    end

    it "can be searched by author name" do
      search_by_text(published_initiative.author.name)

      expect(page).to have_content(translated(published_initiative.title))
    end

    it "can be searched by author nickname" do
      search_by_text(published_initiative.author.nickname)

      expect(page).to have_content(translated(published_initiative.title))
    end

    it_behaves_like "paginating a collection"
  end
end
