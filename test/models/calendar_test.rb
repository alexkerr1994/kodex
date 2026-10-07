require "test_helper"

class CalendarTest < ActiveSupport::TestCase
  setup do
    @user = User.create!(name: "Cal", email: "cal@test.com", password: "password123")
  end

  test "color_for is deterministic and within the palette" do
    assert_includes Calendar::PALETTE, Calendar.color_for("Personal")
    assert_equal Calendar.color_for("Personal"), Calendar.color_for("Personal")
  end

  test "name is required and unique per user (case-insensitive)" do
    @user.calendars.create!(name: "Work", color: "#111")
    dup = @user.calendars.build(name: "work", color: "#222")
    assert_not dup.valid?
    assert_includes dup.errors[:name], "has already been taken"
  end

  test "the same name is allowed for different users" do
    @user.calendars.create!(name: "Work", color: "#111")
    other = User.create!(name: "Other", email: "other@test.com", password: "password123")
    assert other.calendars.build(name: "Work", color: "#111").valid?
  end
end
