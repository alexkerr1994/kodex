require "test_helper"

class NetworksTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @alice = User.create!(name: "Alice", email: "alice@test.com", password: "password123")
    @bob   = User.create!(name: "Bob",   email: "bob@test.com",   password: "password123")
    @carol = User.create!(name: "Carol", email: "carol@test.com", password: "password123")
  end

  def network_with_admin(user, name: "Team")
    net = Network.create!(name: name)
    net.network_memberships.create!(user: user, role: :admin)
    net
  end

  test "creating a network makes you its admin" do
    sign_in @alice
    assert_difference -> { Network.count }, 1 do
      post networks_path, params: { network: { name: "Design" } }
    end
    net = Network.find_by(name: "Design")
    assert_redirected_to net
    assert net.admin?(@alice)
  end

  test "networks index redirects to the Settings networks tab" do
    sign_in @alice
    get networks_path
    assert_redirected_to profile_path(tab: "networks")
  end

  test "the Settings networks tab lists your networks and invitations, scoped to you" do
    mine = network_with_admin(@alice, name: "Mine")
    theirs = network_with_admin(@bob, name: "Theirs")
    theirs.network_invitations.create!(invited_user: @alice, invited_by: @bob)

    sign_in @alice
    get profile_path(tab: "networks")
    assert_response :success
    assert_select ".member-name", text: /Mine/
    assert_select ".member-name", text: /Theirs/ # only as an invitation, not membership
    assert_select ".member-name", text: "Theirs", count: 0 # not listed as a joined network
  end

  test "admin invites an existing user; unknown and duplicate rejected" do
    net = network_with_admin(@alice)
    sign_in @alice

    assert_difference -> { NetworkInvitation.count }, 1 do
      post network_invitations_path(net), params: { email: "bob@test.com" }
    end
    assert net.reload.network_invitations.exists?(invited_user: @bob)

    assert_no_difference -> { NetworkInvitation.count } do
      post network_invitations_path(net), params: { email: "nobody@nowhere.com" }
      post network_invitations_path(net), params: { email: "alice@test.com" } # already a member
    end
  end

  test "invitee accepts an invitation to join" do
    net = network_with_admin(@alice)
    inv = net.network_invitations.create!(invited_user: @bob, invited_by: @alice)
    sign_in @bob
    assert_difference -> { NetworkMembership.count }, 1 do
      post accept_invitation_path(inv)
    end
    assert net.reload.member?(@bob)
    assert_not NetworkInvitation.exists?(inv.id)
  end

  test "invitee declines an invitation" do
    net = network_with_admin(@alice)
    inv = net.network_invitations.create!(invited_user: @bob, invited_by: @alice)
    sign_in @bob
    delete decline_invitation_path(inv)
    assert_not NetworkInvitation.exists?(inv.id)
    assert_not net.reload.member?(@bob)
  end

  test "a non-admin member cannot invite or remove" do
    net = network_with_admin(@alice)
    net.network_memberships.create!(user: @bob, role: :member)
    sign_in @bob
    assert_no_difference -> { NetworkInvitation.count } do
      post network_invitations_path(net), params: { email: "carol@test.com" }
    end
    assert_redirected_to notes_path
  end

  test "demoting the last admin is blocked" do
    net = network_with_admin(@alice)
    admin_membership = net.network_memberships.find_by(user: @alice)
    sign_in @alice
    patch network_membership_path(net, admin_membership), params: { role: "member" }
    assert admin_membership.reload.admin?
  end

  test "removing the sole member deletes the network" do
    net = network_with_admin(@alice)
    admin_membership = net.network_memberships.find_by(user: @alice)
    sign_in @alice
    assert_difference -> { Network.count }, -1 do
      delete network_membership_path(net, admin_membership)
    end
    assert_redirected_to profile_path(tab: "networks")
  end

  test "an admin can't be removed while other members remain without another admin" do
    net = network_with_admin(@alice)
    net.network_memberships.create!(user: @bob, role: :member)
    admin_membership = net.network_memberships.find_by(user: @alice)
    sign_in @alice
    delete network_membership_path(net, admin_membership)
    assert NetworkMembership.exists?(admin_membership.id) # kept: network still has members needing an admin
  end

  test "admin removes a member" do
    net = network_with_admin(@alice)
    net.network_memberships.create!(user: @bob, role: :member)
    bob_membership = net.network_memberships.find_by(user: @bob)
    sign_in @alice
    assert_difference -> { NetworkMembership.count }, -1 do
      delete network_membership_path(net, bob_membership)
    end
    assert_not net.reload.member?(@bob)
  end

  test "a member can leave a network" do
    net = network_with_admin(@alice)
    net.network_memberships.create!(user: @bob, role: :member)
    sign_in @bob
    assert_difference -> { NetworkMembership.count }, -1 do
      delete network_leave_path(net)
    end
    assert_not net.reload.member?(@bob)
    assert_redirected_to profile_path(tab: "networks")
  end

  test "a non-admin leaving cannot promote anyone via successor_id" do
    net = network_with_admin(@alice)
    net.network_memberships.create!(user: @bob, role: :member)
    net.network_memberships.create!(user: @carol, role: :member)
    carol_membership = net.network_memberships.find_by(user: @carol)
    sign_in @bob
    # Bob (a plain member) tries to crown Carol an admin on his way out.
    delete network_leave_path(net), params: { successor_id: carol_membership.id }
    assert_not net.reload.member?(@bob)       # he still left
    assert_not net.admin?(@carol)             # but Carol was NOT promoted
    assert carol_membership.reload.member?
  end

  test "sole admin leaving without a successor is blocked" do
    net = network_with_admin(@alice)
    net.network_memberships.create!(user: @bob, role: :member)
    sign_in @alice
    delete network_leave_path(net)
    assert net.reload.member?(@alice)
    assert_redirected_to net
  end

  test "sole admin can elect a successor and leave" do
    net = network_with_admin(@alice)
    net.network_memberships.create!(user: @bob, role: :member)
    bob_membership = net.network_memberships.find_by(user: @bob)
    sign_in @alice
    delete network_leave_path(net), params: { successor_id: bob_membership.id }
    assert_not net.reload.member?(@alice)
    assert net.admin?(@bob)
  end

  test "an admin can leave when another admin remains" do
    net = network_with_admin(@alice)
    net.network_memberships.create!(user: @bob, role: :admin)
    sign_in @alice
    delete network_leave_path(net)
    assert_not net.reload.member?(@alice)
    assert net.admin?(@bob)
  end

  test "leaving as the last member deletes the network" do
    net = network_with_admin(@alice)
    sign_in @alice
    assert_difference -> { Network.count }, -1 do
      delete network_leave_path(net)
    end
  end

  test "a non-member cannot view a network" do
    net = network_with_admin(@alice)
    sign_in @carol
    get network_path(net)
    assert_redirected_to notes_path
  end
end
