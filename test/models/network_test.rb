require "test_helper"

class NetworkTest < ActiveSupport::TestCase
  setup do
    @alice = User.create!(name: "Alice", email: "alice@test.com", password: "password123")
    @bob   = User.create!(name: "Bob",   email: "bob@test.com",   password: "password123")
    @net = Network.create!(name: "Team")
    @admin_m  = @net.network_memberships.create!(user: @alice, role: :admin)
    @member_m = @net.network_memberships.create!(user: @bob,   role: :member)
  end

  test "requires a name" do
    assert_not Network.new.valid?
  end

  test "member? and admin?" do
    assert @net.member?(@alice)
    assert @net.member?(@bob)
    assert @net.admin?(@alice)
    assert_not @net.admin?(@bob)
    stranger = User.create!(name: "S", email: "s@test.com", password: "password123")
    assert_not @net.member?(stranger)
  end

  test "membership_for finds a user's membership" do
    assert_equal @admin_m, @net.membership_for(@alice)
    assert_nil @net.membership_for(User.create!(name: "X", email: "x@test.com", password: "password123"))
  end

  test "other_admins? ignores the given membership" do
    # Alice is the only admin, so excluding her leaves none.
    assert_not @net.other_admins?(@admin_m)

    @member_m.update!(role: :admin)
    assert @net.reload.other_admins?(@admin_m) # Bob is now another admin
  end
end
