require "test_helper"

class EventTest < ActiveSupport::TestCase
  setup do
    @user = User.create!(name: "Ann", email: "ann@test.com", password: "password123")
    @calendar = @user.calendars.create!(name: "Personal", color: "#333")
  end

  def event(attrs = {})
    @calendar.events.create!({ title: "Thing", starts_at: Time.zone.local(2026, 1, 15, 9, 0) }.merge(attrs))
  end

  test "a one-off event appears only on its own date" do
    e = event(starts_at: Time.zone.local(2026, 1, 15, 9, 0))
    assert_equal [ Date.new(2026, 1, 15) ], e.occurrence_dates(Date.new(2026, 1, 1), Date.new(2026, 1, 31))
    assert_empty e.occurrence_dates(Date.new(2026, 2, 1), Date.new(2026, 2, 28))
  end

  test "weekly recurrence lands every 7 days from the anchor" do
    e = event(starts_at: Time.zone.local(2026, 1, 1, 9, 0), recurrence: :weekly)
    dates = e.occurrence_dates(Date.new(2026, 1, 1), Date.new(2026, 1, 31))
    assert_equal [ 1, 8, 15, 22, 29 ].map { |d| Date.new(2026, 1, d) }, dates
  end

  test "monthly month-end recurrence is computed from the anchor, not compounding" do
    # Jan 31 monthly must not drift to Feb 28 then stick at the 28th (H2 fix).
    e = event(starts_at: Time.zone.local(2026, 1, 31, 9, 0), recurrence: :monthly)
    assert_includes e.occurrence_dates(Date.new(2026, 3, 1), Date.new(2026, 3, 31)), Date.new(2026, 3, 31)
    assert_includes e.occurrence_dates(Date.new(2026, 5, 1), Date.new(2026, 5, 31)), Date.new(2026, 5, 31)
  end

  test "recurrence_until bounds the series" do
    e = event(starts_at: Time.zone.local(2026, 1, 1, 9, 0), recurrence: :weekly,
              recurrence_until: Date.new(2026, 1, 15))
    dates = e.occurrence_dates(Date.new(2026, 1, 1), Date.new(2026, 1, 31))
    assert_equal [ Date.new(2026, 1, 1), Date.new(2026, 1, 8), Date.new(2026, 1, 15) ], dates
  end

  test "occurrence anchor uses the display zone" do
    # A time near midnight should bucket on the zone-local date, not the UTC date.
    e = event(starts_at: Time.zone.local(2026, 1, 15, 23, 30))
    assert_equal [ Date.new(2026, 1, 15) ], e.occurrence_dates(Date.new(2026, 1, 1), Date.new(2026, 1, 31))
  end

  test "ends_at must be after starts_at" do
    e = @calendar.events.build(title: "Bad", starts_at: Time.zone.local(2026, 1, 15, 10, 0),
                               ends_at: Time.zone.local(2026, 1, 15, 9, 0))
    assert_not e.valid?
    assert_includes e.errors[:ends_at], "must be after the start"
  end
end
