require "test_helper"

class TagTest < ActiveSupport::TestCase
  setup do
    @user = User.create!(name: "Tagger", email: "tagger@test.com", password: "password123")
  end

  test "color_for is deterministic and within the palette" do
    assert_includes Tag::PALETTE, Tag.color_for("urgent")
    assert_equal Tag.color_for("urgent"), Tag.color_for("urgent")
  end

  test "name is required and unique per user (case-insensitive)" do
    @user.tags.create!(name: "Urgent", color: "#f00")
    dup = @user.tags.build(name: "urgent", color: "#0f0")
    assert_not dup.valid?
    assert_includes dup.errors[:name], "has already been taken"
  end

  test "the same tag name is allowed for different users" do
    @user.tags.create!(name: "Urgent", color: "#f00")
    other = User.create!(name: "Other", email: "other@test.com", password: "password123")
    assert other.tags.build(name: "Urgent", color: "#f00").valid?
  end
end
