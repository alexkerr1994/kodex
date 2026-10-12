require "test_helper"

class FriendshipsTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @alice = User.create!(name: "Alice", email: "alice@test.com", username: "alice", password: "password123")
    @bob   = User.create!(name: "Bob",   email: "bob@test.com",   username: "bob",   password: "password123")
  end

  test "send a friend request by username, then accept it" do
    sign_in @alice
    assert_difference -> { Friendship.count }, 1 do
      post friendships_path, params: { identifier: "bob" }
    end
    friendship = Friendship.last
    assert friendship.pending?
    assert_equal @alice, friendship.requester

    sign_in @bob
    post accept_friendship_path(friendship)
    assert friendship.reload.accepted?
    assert @alice.reload.friends_with?(@bob)
  end

  test "you can also add by email" do
    sign_in @alice
    assert_difference -> { Friendship.count }, 1 do
      post friendships_path, params: { identifier: "BOB@test.com" } # case-insensitive
    end
  end

  test "cannot friend yourself or an unknown handle" do
    sign_in @alice
    assert_no_difference -> { Friendship.count } do
      post friendships_path, params: { identifier: "alice" }
      post friendships_path, params: { identifier: "ghost" }
    end
  end

  test "cannot send a duplicate request in either direction" do
    Friendship.create!(requester: @alice, addressee: @bob)
    sign_in @bob
    assert_no_difference -> { Friendship.count } do
      post friendships_path, params: { identifier: "alice" }
    end
  end

  test "only the addressee can accept a request" do
    carol = User.create!(name: "Carol", email: "carol@test.com", username: "carol", password: "password123")
    friendship = Friendship.create!(requester: @alice, addressee: @bob)
    sign_in carol
    post accept_friendship_path(friendship)
    assert_response :not_found
    assert friendship.reload.pending?
  end

  test "declining / unfriending removes the row" do
    friendship = Friendship.create!(requester: @alice, addressee: @bob, status: :accepted)
    sign_in @bob
    assert_difference -> { Friendship.count }, -1 do
      delete friendship_path(friendship)
    end
  end

  test "you can share a note with a friend who shares no network" do
    friendship = Friendship.create!(requester: @alice, addressee: @bob, status: :accepted)
    note = Note.create!(owner: @alice, title: "N", last_edited_by: @alice)
    sign_in @alice
    assert_difference -> { note.note_memberships.count }, 1 do
      post note_shares_path(note), params: { share_with: "user:#{@bob.id}", access_level: "viewer" },
           headers: { "Accept" => "text/vnd.turbo-stream.html" }
    end
    assert note.reload.readable_by?(@bob)
  end

  test "you cannot share a note with a stranger via the people picker" do
    stranger = User.create!(name: "Stranger", email: "stranger@test.com", password: "password123")
    note = Note.create!(owner: @alice, title: "N", last_edited_by: @alice)
    sign_in @alice
    assert_no_difference -> { note.note_memberships.count } do
      post note_shares_path(note), params: { share_with: "user:#{stranger.id}", access_level: "viewer" },
           headers: { "Accept" => "text/vnd.turbo-stream.html" }
    end
  end
end
