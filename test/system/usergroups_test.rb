require "application_system_test_case"

class UsergroupsTest < ApplicationSystemTestCase
  setup do
    @usergroup = usergroups(:one)
  end

  test "visiting the index" do
    visit usergroups_url
    assert_selector "h1", text: "Usergroups"
  end

  test "creating a Usergroup" do
    visit usergroups_url
    click_on "New Usergroup"

    check "Bespoke" if @usergroup.bespoke
    check "Draggable" if @usergroup.draggable
    fill_in "East", with: @usergroup.east
    fill_in "Name", with: @usergroup.name
    fill_in "North", with: @usergroup.north
    fill_in "South", with: @usergroup.south
    fill_in "West", with: @usergroup.west
    click_on "Create Usergroup"

    assert_text "Usergroup was successfully created"
    click_on "Back"
  end

  test "updating a Usergroup" do
    visit usergroups_url
    click_on "Edit", match: :first

    check "Bespoke" if @usergroup.bespoke
    check "Draggable" if @usergroup.draggable
    fill_in "East", with: @usergroup.east
    fill_in "Name", with: @usergroup.name
    fill_in "North", with: @usergroup.north
    fill_in "South", with: @usergroup.south
    fill_in "West", with: @usergroup.west
    click_on "Update Usergroup"

    assert_text "Usergroup was successfully updated"
    click_on "Back"
  end

  test "destroying a Usergroup" do
    visit usergroups_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Usergroup was successfully destroyed"
  end
end
