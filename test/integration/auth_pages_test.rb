require "test_helper"

class AuthPagesTest < ActionDispatch::IntegrationTest
  test "sign-in page renders in the auth layout (no redirect loop)" do
    get new_user_session_path
    assert_response :success
    assert_select "body.auth-body"
    assert_select ".auth-panel"
    assert_select "h1.auth-title"
    assert_select "input[name=?]", "user[login]" # username-or-email field
    assert_select "input[name=?]", "user[password]"
  end

  test "you can sign in with a username or an email" do
    user = User.create!(name: "Pat", email: "pat@test.com", username: "patty", password: "password123")

    post user_session_path, params: { user: { login: "patty", password: "password123" } }
    assert_redirected_to root_path
    delete destroy_user_session_path

    post user_session_path, params: { user: { login: "pat@test.com", password: "password123" } }
    assert_redirected_to root_path
    delete destroy_user_session_path

    post user_session_path, params: { user: { login: "nope", password: "password123" } }
    assert_response :unprocessable_entity
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
