require "test_helper"

class NoteNetworkSharingTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @owner = User.create!(name: "Owner", email: "owner@test.com", password: "password123")
    @alice = User.create!(name: "Alice", email: "alice@test.com", password: "password123")
    @bob   = User.create!(name: "Bob",   email: "bob@test.com",   password: "password123")
    @net = Network.create!(name: "Team")
    @net.network_memberships.create!(user: @owner, role: :admin)
    @net.network_memberships.create!(user: @alice, role: :member)
    @net.network_memberships.create!(user: @bob, role: :member)
    @note = Note.create!(owner: @owner, title: "Shared with team", body: "hi")
  end

  test "sharing with a network grants read access to its members" do
    sign_in @owner
    assert_difference -> { NoteNetworkShare.count }, 1 do
      post note_shares_path(@note), params: { share_with: "network:#{@net.id}", access_level: "viewer" }
    end
    assert @note.reload.readable_by?(@alice)
    assert_not @note.editable_by?(@alice) # viewer only

    # The note now shows up in a member's list and is viewable.
    sign_in @alice
    get notes_path
    assert_select ".n-card .n-title", text: "Shared with team"
    get note_path(@note)
    assert_response :success
  end

  test "an editor network share grants edit access" do
    @note.note_network_shares.create!(network: @net, access_level: :editor)
    assert @note.reload.editable_by?(@bob)
  end

  test "removing a network share revokes access" do
    share = @note.note_network_shares.create!(network: @net, access_level: :viewer)
    assert @note.reload.readable_by?(@alice)
    sign_in @owner
    delete note_network_share_path(@note, share)
    assert_not @note.reload.readable_by?(@alice)
  end

  test "sharing with a person from your networks creates a direct membership" do
    sign_in @owner
    assert_difference -> { NoteMembership.count }, 1 do
      post note_shares_path(@note), params: { share_with: "user:#{@alice.id}", access_level: "editor" }
    end
    assert_equal "editor", @note.reload.membership_for(@alice).access_level
  end

  test "cannot share with a network you don't belong to" do
    other = Network.create!(name: "Strangers")
    other.network_memberships.create!(user: @alice, role: :admin)
    sign_in @owner
    assert_no_difference -> { NoteNetworkShare.count } do
      post note_shares_path(@note), params: { share_with: "network:#{other.id}" }
    end
  end

  test "cannot share with a person not in your networks" do
    stranger = User.create!(email: "stranger@test.com", password: "password123")
    sign_in @owner
    assert_no_difference -> { NoteMembership.count } do
      post note_shares_path(@note), params: { share_with: "user:#{stranger.id}" }
    end
  end

  test "the share pane lists networks and offers the picker" do
    @note.note_network_shares.create!(network: @net, access_level: :viewer)
    sign_in @owner
    get note_path(@note)
    assert_select "#note_sharing .member-name", text: "Team"
    assert_select "select[name=share_with]"
  end
end
