require "test_helper"

class FavoritesTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @owner  = User.create!(name: "Owner", email: "o@test.com", password: "password123")
    @viewer = User.create!(name: "Viewer", email: "v@test.com", password: "password123")
    @note = Note.create!(owner: @owner, title: "N", body: "x")
    @note.note_memberships.create!(user: @viewer, access_level: :viewer)
  end

  test "favouriting is per-user and toggles on/off" do
    sign_in @viewer
    assert_difference -> { @viewer.favorites.count }, 1 do
      post note_favorite_path(@note), headers: { "Accept" => "text/vnd.turbo-stream.html" }
    end
    assert @note.reload.favorited_by?(@viewer)
    assert_not @note.favorited_by?(@owner) # personal to the viewer

    assert_difference -> { @viewer.favorites.count }, -1 do
      delete note_favorite_path(@note), headers: { "Accept" => "text/vnd.turbo-stream.html" }
    end
    assert_not @note.reload.favorited_by?(@viewer)
  end

  test "the turbo stream refreshes the star and the sidebar count" do
    sign_in @owner
    post note_favorite_path(@note), headers: { "Accept" => "text/vnd.turbo-stream.html" }
    assert_match %r{target="note_favorite_#{@note.id}"}, @response.body
    assert_match %r{target="fav_count"}, @response.body
  end

  test "the Favorites filter shows only favourited notes" do
    other = Note.create!(owner: @owner, title: "Other", body: "y")
    @owner.favorites.create!(note: @note)
    sign_in @owner

    get notes_path(filter: "favorites")
    assert_response :success
    assert_select ".n-card .n-title", text: "N"
    assert_select ".n-card .n-title", text: "Other", count: 0
    assert_select ".sidebar .nav-item.active .label", text: "Favorites"
  end

  test "a viewer can favourite a note they can see" do
    sign_in @viewer
    post note_favorite_path(@note), headers: { "Accept" => "text/vnd.turbo-stream.html" }
    assert_response :success
    assert @note.reload.favorited_by?(@viewer)
  end
end
