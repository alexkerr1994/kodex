require "test_helper"

class ProfileTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
  include ActionMailer::TestHelper

  setup do
    @user = User.create!(name: "Sam", email: "sam@test.com", password: "password123")
  end

  test "requires sign in" do
    get profile_path
    assert_redirected_to new_user_session_path
  end

  test "shows the tabbed settings page" do
    sign_in @user
    get profile_path
    assert_response :success
    # It lives inside the standard app shell (sidebar + content), not a standalone page.
    assert_select ".app-shell--settings .sidebar .brand"
    assert_select ".settings-area"
    # Four tabs: Account, App, Organization, Networks.
    assert_select ".settings-tabs .tab[data-name=?]", "account", text: "Account"
    %w[account app organization networks].each { |t| assert_select ".settings-tabs .tab[data-name=?]", t }
    assert_select ".settings-tabs .tab", count: 4
    assert_select "input[name=?][value=?]", "user[theme]", "quill" # App tab
    assert_select "select[name=?]", "user[time_zone]"              # App tab
    assert_select "select[name=?]", "user[default_view]"          # App tab
    assert_select "input[name=?]", "user[current_password]"       # Account tab
    assert_select "input[type=file][name=?]", "user[avatar]"      # Account tab (Profile)
    assert_select "input[name=?]", "user[username]"               # Account tab (Profile)
    assert_select "#tags_manager"       # Organization tab
    assert_select "#calendars_manager"  # Organization tab
    assert_select ".danger-zone"        # Account tab
    assert_select ".referral-form input[name=?]", "email" # Account tab (referral)
  end

  test "profile fields update name, theme, timezone and defaults" do
    sign_in @user
    patch profile_path, params: { return_tab: "app", user: {
      name: "Samuel", theme: "modern", time_zone: "London",
      default_view: "board", start_collapsed: "1"
    } }
    assert_redirected_to profile_path(tab: "app")
    @user.reload
    assert_equal "Samuel", @user.name
    assert_equal "modern", @user.theme
    assert_equal "London", @user.time_zone
    assert_equal "board", @user.default_view
    assert @user.start_collapsed
  end

  test "default_view board opens the board without a view param" do
    @user.update!(default_view: "board")
    sign_in @user
    get notes_path
    assert_select ".board"
  end

  test "rejects an unknown theme" do
    sign_in @user
    patch profile_path, params: { user: { theme: "neon" } }
    assert_response :unprocessable_entity
    assert_equal "quill", @user.reload.theme
  end

  test "account tab changes email with the correct current password" do
    sign_in @user
    patch profile_account_path, params: { user: { email: "new@test.com", current_password: "password123" } }
    assert_redirected_to profile_path(tab: "account")
    assert_equal "new@test.com", @user.reload.email
  end

  test "account tab changes password and keeps the session alive" do
    sign_in @user
    patch profile_account_path, params: {
      user: { password: "newsecret9", password_confirmation: "newsecret9", current_password: "password123" }
    }
    assert_redirected_to profile_path(tab: "account")
    assert @user.reload.valid_password?("newsecret9")
    follow_redirect! # still authenticated (bypass_sign_in)
    assert_response :success
  end

  test "account update fails with the wrong current password" do
    sign_in @user
    patch profile_account_path, params: { user: { email: "x@test.com", current_password: "WRONG" } }
    assert_response :unprocessable_entity
    assert_equal "sam@test.com", @user.reload.email
  end

  test "devise account-edit page redirects to the Account tab" do
    sign_in @user
    get "/users/edit"
    assert_redirected_to "/profile?tab=account"
  end

  test "the chosen theme is applied in the layout" do
    @user.update!(theme: "modern")
    sign_in @user
    get notes_path
    assert_select "html[data-theme=?]", "modern"
  end

  test "an attached avatar renders as a resized variant image" do
    @user.avatar.attach(io: StringIO.new("img"), filename: "a.png", content_type: "image/png")
    sign_in @user
    get profile_path
    assert_select "img.avatar-img" # variant thumbnail, not the initial letter
  end

  test "removing the avatar via the checkbox purges it" do
    @user.avatar.attach(io: StringIO.new("x"), filename: "a.png", content_type: "image/png")
    assert @user.avatar.attached?
    sign_in @user
    patch profile_path, params: { user: { name: "Sam", remove_avatar: "1" } }
    assert_not @user.reload.avatar.attached?
  end

  test "managing tags: rename, recolour and delete" do
    tag = @user.tags.create!(name: "Work", color: "#111111")
    sign_in @user

    patch tag_path(tag), params: { tag: { name: "Career", color: "#222222" } },
          headers: { "Accept" => "text/vnd.turbo-stream.html" }
    assert_response :success
    tag.reload
    assert_equal "Career", tag.name
    assert_equal "#222222", tag.color

    assert_difference -> { @user.tags.count }, -1 do
      delete tag_path(tag)
    end
  end

  test "renaming a tag to a duplicate name returns an inline error" do
    @user.tags.create!(name: "Work", color: "#111111")
    other = @user.tags.create!(name: "Home", color: "#222222")
    sign_in @user
    patch tag_path(other), params: { tag: { name: "Work" } },
          headers: { "Accept" => "text/vnd.turbo-stream.html" }
    assert_match "tags_manager", @response.body
    assert_match(/already been taken|taken/i, @response.body)
    assert_equal "Home", other.reload.name
  end

  test "you cannot edit another user's tag" do
    other_user = User.create!(email: "other@test.com", password: "password123")
    their_tag = other_user.tags.create!(name: "Secret", color: "#333333")
    sign_in @user
    patch tag_path(their_tag), params: { tag: { name: "Hacked" } }
    assert_response :not_found
    assert_equal "Secret", their_tag.reload.name
  end

  test "referral sends an invite email to a valid address" do
    sign_in @user
    assert_enqueued_emails 1 do
      post profile_referral_path, params: { email: "friend@test.com" }
    end
    assert_redirected_to profile_path(tab: "account")
  end

  test "referral rejects an invalid email" do
    sign_in @user
    assert_no_enqueued_emails do
      post profile_referral_path, params: { email: "not-an-email" }
    end
    assert_redirected_to profile_path(tab: "account")
  end

  test "danger zone deletes the account and its notes" do
    Note.create!(owner: @user, title: "Mine", body: "x")
    sign_in @user
    assert_difference -> { User.count }, -1 do
      assert_difference -> { Note.count }, -1 do
        delete profile_path
      end
    end
    assert_redirected_to new_user_session_path
  end
end
