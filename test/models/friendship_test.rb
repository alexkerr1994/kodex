require "test_helper"

class FriendshipTest < ActiveSupport::TestCase
  setup do
    @a = User.create!(name: "A", email: "a@test.com", password: "password123")
    @b = User.create!(name: "B", email: "b@test.com", password: "password123")
  end

  test "defaults to pending" do
    f = Friendship.create!(requester: @a, addressee: @b)
    assert f.pending?
  end

  test "cannot befriend yourself" do
    assert_not Friendship.new(requester: @a, addressee: @a).valid?
  end

  test "cannot duplicate a friendship in either direction" do
    Friendship.create!(requester: @a, addressee: @b)
    assert_not Friendship.new(requester: @a, addressee: @b).valid? # same direction
    assert_not Friendship.new(requester: @b, addressee: @a).valid? # reverse
  end

  test "between finds the row in either direction" do
    f = Friendship.create!(requester: @a, addressee: @b)
    assert_equal f, Friendship.between(@a, @b)
    assert_equal f, Friendship.between(@b, @a)
    assert_nil Friendship.between(@a, User.create!(email: "c@test.com", password: "password123"))
  end
end
