require "test_helper"

class CalendarsTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = User.create!(name: "Sam", email: "sam@test.com", password: "password123")
    @other = User.create!(name: "Pat", email: "pat@test.com", password: "password123")
  end

  test "visiting the calendar auto-creates a default calendar and renders the month grid" do
    sign_in @user
    assert_difference -> { @user.calendars.count }, 1 do
      get calendar_path
    end
    assert_response :success
    assert_select ".cal-month .cal-day", minimum: 28
    assert_equal "Personal", @user.calendars.first.name
  end

  test "creating an event places it on its day" do
    sign_in @user
    cal = @user.calendars.create!(name: "Personal", color: "#a06e57")
    when_at = Time.zone.local(2026, 6, 15, 9, 0)
    assert_difference -> { Event.count }, 1 do
      post events_path, params: { event: { calendar_id: cal.id, title: "Dentist", starts_at: when_at, recurrence: "once" } }
    end
    assert_redirected_to calendar_path(year: 2026, month: 6)

    get calendar_path(year: 2026, month: 6)
    assert_select ".cal-event", text: /Dentist/
  end

  test "you cannot create an event on someone else's calendar" do
    theirs = @other.calendars.create!(name: "Theirs", color: "#111111")
    sign_in @user
    assert_no_difference -> { Event.count } do
      post events_path, params: { event: { calendar_id: theirs.id, title: "Sneaky", starts_at: Time.current, recurrence: "once" } }
    end
    assert_response :not_found
  end

  test "a weekly recurring event appears on each week in the month" do
    cal = @user.calendars.create!(name: "Personal", color: "#a06e57")
    event = cal.events.create!(title: "Standup", starts_at: Time.zone.local(2026, 6, 1, 9, 0),
                               recurrence: "weekly")
    dates = event.occurrence_dates(Date.new(2026, 6, 1), Date.new(2026, 6, 30))
    assert_equal [1, 8, 15, 22, 29].map { |d| Date.new(2026, 6, d) }, dates
  end

  test "recurrence stops at recurrence_until" do
    cal = @user.calendars.create!(name: "Personal", color: "#a06e57")
    event = cal.events.create!(title: "Daily", starts_at: Time.zone.local(2026, 6, 1, 9, 0),
                               recurrence: "daily", recurrence_until: Date.new(2026, 6, 3))
    dates = event.occurrence_dates(Date.new(2026, 6, 1), Date.new(2026, 6, 30))
    assert_equal [1, 2, 3].map { |d| Date.new(2026, 6, d) }, dates
  end

  test "the week view renders a 7-day time grid with positioned events" do
    sign_in @user
    cal = @user.calendars.create!(name: "Personal", color: "#a06e57")
    cal.events.create!(title: "Standup", starts_at: Time.zone.local(2026, 6, 15, 9, 0),
                       ends_at: Time.zone.local(2026, 6, 15, 9, 30))
    get calendar_path(cal_view: "week", date: "2026-06-15")
    assert_response :success
    assert_select ".cal-week"
    assert_select ".cal-week-dayhead", count: 7
    assert_select ".cal-wevent", text: /Standup/
  end

  test "clicking an event loads its details into the popover frame" do
    sign_in @user
    cal = @user.calendars.create!(name: "Personal", color: "#a06e57")
    e = cal.events.create!(title: "Dentist", starts_at: Time.zone.local(2026, 6, 15, 9, 0),
                           ends_at: Time.zone.local(2026, 6, 15, 10, 0))
    get event_path(e, date: "2026-06-15")
    assert_response :success
    assert_select "turbo-frame#event_detail .event-pop-title", text: "Dentist"
    assert_select ".event-pop-when", text: /15 June 2026/
    assert_select "a[href=?]", edit_event_path(e) # edit link inside the popover
  end

  test "day cells carry a new-event url and events target the popover frame" do
    sign_in @user
    cal = @user.calendars.create!(name: "Personal", color: "#a06e57")
    cal.events.create!(title: "X", starts_at: Time.zone.local(2026, 6, 15, 9, 0))
    get calendar_path(year: 2026, month: 6)
    assert_select ".cal-day[data-new-url]"
    assert_select ".cal-event[data-turbo-frame=event_detail]"
  end

  test "you cannot view another user's event" do
    other_cal = @other.calendars.create!(name: "Theirs", color: "#111111")
    e = other_cal.events.create!(title: "Secret", starts_at: Time.current)
    sign_in @user
    get event_path(e)
    assert_response :not_found
  end

  test "the month/week toggle is present" do
    sign_in @user
    get calendar_path
    assert_select ".view-toggle a", text: "Month"
    assert_select ".view-toggle a", text: "Week"
  end

  test "deleting a calendar deletes its events" do
    cal = @user.calendars.create!(name: "Work", color: "#111111")
    cal.events.create!(title: "X", starts_at: Time.current)
    sign_in @user
    assert_difference -> { Event.count }, -1 do
      delete manage_calendar_path(cal), headers: { "Accept" => "text/vnd.turbo-stream.html" }
    end
  end

  test "settings has a Calendars tab with a create form" do
    sign_in @user
    get profile_path
    assert_select ".settings-tabs .tab[data-name=?]", "organization" # Calendars live under Organization
    assert_select "#calendars_manager"
  end

  test "the new-event form renders inside the popover frame" do
    sign_in @user
    @user.calendars.create!(name: "Personal", color: "#a06e57")
    get new_event_path(date: "2026-06-15")
    assert_response :success
    assert_select "turbo-frame#event_detail form"
  end

  test "a week-view hour click preloads that time into the new-event form" do
    sign_in @user
    @user.calendars.create!(name: "Personal", color: "#a06e57")
    get new_event_path(date: "2026-06-15", hour: 14)
    assert_response :success
    assert_select "input#event_starts_at[value*=?]", "T14:00"
  end

  test "an out-of-range hour is clamped" do
    sign_in @user
    @user.calendars.create!(name: "Personal", color: "#a06e57")
    get new_event_path(date: "2026-06-15", hour: 99)
    assert_response :success
    assert_select "input#event_starts_at[value*=?]", "T23:00"
  end

  test "a selected holiday region overlays public holidays on the month grid" do
    @user.update!(holiday_region: "my")
    sign_in @user
    get calendar_path(year: 2026, month: 1)
    assert_response :success
    assert_select ".cal-day.is-holiday" # the day background is flagged
    assert_select ".cal-holiday", text: /New Year's Day/ # and the name is labelled
  end

  test "no holiday overlay when no region is selected" do
    sign_in @user
    get calendar_path(year: 2026, month: 1)
    assert_select ".cal-day.is-holiday", count: 0
  end

  test "a multi-day event renders as a single spanning bar, not per-day chips" do
    sign_in @user
    cal = @user.calendars.create!(name: "Personal", color: "#a06e57")
    cal.events.create!(title: "Conference", all_day: true,
                       starts_at: Time.zone.local(2026, 6, 10, 0, 0),
                       ends_at: Time.zone.local(2026, 6, 12, 0, 0))
    get calendar_path(year: 2026, month: 6)
    assert_response :success
    assert_select ".cal-span .cal-span-title", text: "Conference"
    assert_select ".cal-event .cal-event-title", text: "Conference", count: 0
  end

  test "dragging a date range preloads an all-day multi-day event form" do
    sign_in @user
    @user.calendars.create!(name: "Personal", color: "#a06e57")
    get new_event_path(date: "2026-06-10", end_date: "2026-06-12")
    assert_response :success
    assert_select "input#event_all_day[checked]"
    assert_select "input#event_starts_at[value*=?]", "2026-06-10"
    assert_select "input#event_ends_at[value*=?]", "2026-06-12"
  end

  test "the month label is a jump-to-month picker" do
    sign_in @user
    get calendar_path(year: 2026, month: 6)
    assert_select "details.month-picker select[name=month]"
    assert_select "details.month-picker select[name=year]"
  end

  test "the Today button is hidden when the current month is in view" do
    sign_in @user
    get calendar_path(year: Date.current.year, month: Date.current.month)
    assert_select "a", text: "Today", count: 0
    get calendar_path(year: 2000, month: 1)
    assert_select "a", text: "Today", count: 1
  end
end
