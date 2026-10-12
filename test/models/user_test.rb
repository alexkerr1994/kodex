require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "username defaults to the email local-part when blank" do
    user = User.create!(email: "jamie.lee@example.com", password: "password123")
    assert_equal "jamie.lee", user.username
  end

  test "a duplicate derived username gets a numeric suffix" do
    first  = User.create!(email: "sam@a.com", password: "password123")
    second = User.create!(email: "sam@b.com", password: "password123")
    assert_equal "sam", first.username
    assert_equal "sam1", second.username
  end

  test "username is normalized to lowercase and trimmed" do
    user = User.create!(email: "x@test.com", username: "  CoolName  ", password: "password123")
    assert_equal "coolname", user.username
  end

  test "username must be unique (case-insensitive)" do
    User.create!(email: "a@test.com", username: "taken", password: "password123")
    dup = User.new(email: "b@test.com", username: "TAKEN", password: "password123")
    assert_not dup.valid?
    assert_includes dup.errors[:username], "has already been taken"
  end

  test "username rejects invalid characters" do
    user = User.new(email: "c@test.com", username: "has spaces", password: "password123")
    assert_not user.valid?
    assert_predicate user.errors[:username], :any?
  end

  test "find_for_database_authentication matches username or email, case-insensitively" do
    user = User.create!(email: "robin@test.com", username: "robin", password: "password123")
    assert_equal user, User.find_for_database_authentication(login: "robin")
    assert_equal user, User.find_for_database_authentication(login: "ROBIN")
    assert_equal user, User.find_for_database_authentication(login: "robin@test.com")
    assert_nil User.find_for_database_authentication(login: "ghost")
  end

  test "display_name falls back to username, not email" do
    named   = User.create!(email: "n@test.com", name: "Nadia", password: "password123")
    unnamed = User.create!(email: "quiet.one@test.com", password: "password123")
    assert_equal "Nadia", named.display_name
    assert_equal "quiet.one", unnamed.display_name
  end

  test "friends are only accepted friendships (either direction), not pending ones" do
    me      = User.create!(name: "Me",      email: "me@test.com",      password: "password123")
    pal     = User.create!(name: "Pal",     email: "pal@test.com",     password: "password123")
    fan     = User.create!(name: "Fan",     email: "fan@test.com",     password: "password123")
    pending = User.create!(name: "Pending", email: "pending@test.com", password: "password123")

    Friendship.create!(requester: me,  addressee: pal, status: :accepted) # I requested, accepted
    Friendship.create!(requester: fan, addressee: me,  status: :accepted) # they requested, accepted
    Friendship.create!(requester: me,  addressee: pending)                # still pending

    names = me.friends.map(&:name)
    assert_includes names, "Pal"
    assert_includes names, "Fan"
    assert_not_includes names, "Pending"
    assert me.friends_with?(pal)
    assert_not me.friends_with?(pending)
  end

  test "incoming and outgoing friend requests" do
    me  = User.create!(name: "Me",  email: "me@test.com",  password: "password123")
    her = User.create!(name: "Her", email: "her@test.com", password: "password123")
    him = User.create!(name: "Him", email: "him@test.com", password: "password123")

    Friendship.create!(requester: her, addressee: me)  # incoming
    Friendship.create!(requester: me,  addressee: him) # outgoing

    assert_equal [ her ], me.incoming_friend_requests.map(&:requester)
    assert_equal [ him ], me.outgoing_friend_requests.map(&:addressee)
  end

  test "shareable_people includes friends and network co-members, not strangers" do
    me       = User.create!(name: "Me",       email: "me@test.com",       password: "password123")
    friend   = User.create!(name: "Friend",   email: "friend@test.com",   password: "password123")
    peer     = User.create!(name: "Peer",     email: "peer@test.com",     password: "password123")
    stranger = User.create!(name: "Stranger", email: "stranger@test.com", password: "password123")

    Friendship.create!(requester: me, addressee: friend, status: :accepted)
    net = Network.create!(name: "Team")
    net.network_memberships.create!(user: me,   role: :admin)
    net.network_memberships.create!(user: peer, role: :member)

    ids = me.shareable_people.pluck(:id)
    assert_includes ids, friend.id
    assert_includes ids, peer.id
    assert_not_includes ids, stranger.id
    assert_not_includes ids, me.id
  end
end
