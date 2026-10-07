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
end
