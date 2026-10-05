require "test_helper"

class AuthPagesTest < ActionDispatch::IntegrationTest
  test "sign-in page renders in the auth layout (no redirect loop)" do
    get new_user_session_path
    assert_response :success
    assert_select "body.auth-body"
    assert_select ".auth-panel"
    assert_select "h1.auth-title"
    assert_select "input[name=?]", "user[email]"
    assert_select "input[name=?]", "user[password]"
  end

  test "forgot-password page renders" do
    get new_user_password_path
    assert_response :success
    assert_select "h1.auth-title"
    assert_select "input[name=?]", "user[email]"
  end

  test "public sign-up is disabled (no registration routes)" do
    helpers = Rails.application.routes.url_helpers
    assert_not helpers.respond_to?(:new_user_registration_path)
    assert_not helpers.respond_to?(:user_registration_path)
  end

  test "the sign-in page does not offer public sign-up" do
    get new_user_session_path
    assert_select "a", text: /Create an account/, count: 0
    assert_select "p.auth-note" # invite-only notice instead
  end
end
