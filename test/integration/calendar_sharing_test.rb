require "test_helper"

class CalendarSharingTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @owner = User.create!(name: "Owner", email: "owner@test.com", password: "password123")
    @alice = User.create!(name: "Alice", email: "alice@test.com", password: "password123")
    @bob   = User.create!(name: "Bob",   email: "bob@test.com",   password: "password123")
    @cal = @owner.calendars.create!(name: "Work", color: "#6b7f9e")
    @event = @cal.events.create!(title: "Launch", starts_at: Time.zone.local(2026, 6, 15, 9, 0),
                                 ends_at: Time.zone.local(2026, 6, 15, 10, 0))
  end

  def network_with(*users)
    net = Network.create!(name: "Team")
    users.each_with_index { |u, i| net.network_memberships.create!(user: u, role: i.zero? ? :admin : :member) }
    net
  end

  test "sharing a calendar with a person lets them see its events (read-only)" do
    @cal.calendar_shares.create!(user: @alice)
    sign_in @alice
    get calendar_path(year: 2026, month: 6)
    assert_response :success
    assert_select ".cal-event", text: /Launch/
    assert_select ".sidebar .nav-label", text: "Shared with you"
  end

  test "a calendar shared with a network is visible to its members" do
    net = network_with(@owner, @bob)
    @cal.calendar_network_shares.create!(network: net)
    sign_in @bob
    get calendar_path(year: 2026, month: 6)
    assert_select ".cal-event", text: /Launch/
  end

  test "a shared event opens read-only (no edit/delete, shows owner)" do
    @cal.calendar_shares.create!(user: @alice)
    sign_in @alice
    get event_path(@event, date: "2026-06-15")
    assert_response :success
    assert_select ".event-pop-title", text: "Launch"
    assert_select "a[href=?]", edit_event_path(@event), count: 0
    assert_select ".event-pop-row", text: /Shared by Owner/
  end

  test "a non-recipient cannot see the event" do
    sign_in @bob
    get event_path(@event)
    assert_response :not_found
  end

  test "a recipient cannot edit or delete the shared event" do
    @cal.calendar_shares.create!(user: @alice)
    sign_in @alice
    get edit_event_path(@event)
    assert_response :not_found
    assert_no_difference -> { Event.count } do
      delete event_path(@event)
    end
  end

  test "the owner can share (by email) and unshare a calendar with a person" do
    sign_in @owner
    assert_difference -> { CalendarShare.count }, 1 do
      post manage_calendar_shares_path(@cal), params: { email: @alice.email },
           headers: { "Accept" => "text/vnd.turbo-stream.html" }
    end
    share = @cal.calendar_shares.find_by(user: @alice)
    assert_difference -> { CalendarShare.count }, -1 do
      delete manage_calendar_share_path(@cal, share), headers: { "Accept" => "text/vnd.turbo-stream.html" }
    end
  end

  test "the owner can share with a person from a network via the picker" do
    network_with(@owner, @alice)
    sign_in @owner
    assert_difference -> { CalendarShare.count }, 1 do
      post manage_calendar_shares_path(@cal), params: { share_with: "user:#{@alice.id}" },
           headers: { "Accept" => "text/vnd.turbo-stream.html" }
    end
    assert @cal.calendar_shares.exists?(user: @alice)
  end

  test "only the owner can open a calendar's sharing page" do
    sign_in @alice
    get manage_calendar_path(@cal)
    assert_response :not_found
  end
end
