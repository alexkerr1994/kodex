require "test_helper"

class BoardTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = User.create!(name: "Sam", email: "sam@test.com", password: "password123")
    @work = @user.tags.create!(name: "Work", color: "#111111")
    @home = @user.tags.create!(name: "Home", color: "#222222")
    @note = Note.create!(owner: @user, title: "N", body: "x")
    @note.note_tags.create!(tag: @work)
  end

  test "dragging a card to another tag column re-tags the note" do
    sign_in @user
    patch move_tag_note_path(@note), params: { from: @work.id, to: @home.id },
          headers: { "Accept" => "text/vnd.turbo-stream.html" }
    assert_response :success
    assert_match %r{turbo-stream action="replace" target="board"}, @response.body
    assert_equal ["Home"], @note.reload.tags_for(@user).map(&:name)
  end

  test "dragging from Untagged adds the destination tag" do
    loose = Note.create!(owner: @user, title: "Loose", body: "x")
    sign_in @user
    patch move_tag_note_path(loose), params: { from: "", to: @home.id }
    assert_equal ["Home"], loose.reload.tags_for(@user).map(&:name)
  end

  test "dragging to the Untagged column removes the source tag" do
    sign_in @user
    patch move_tag_note_path(@note), params: { from: @work.id, to: "" }
    assert_empty @note.reload.tags_for(@user)
  end

  test "only your own tags are used when moving" do
    other = User.create!(email: "other@test.com", password: "password123")
    their_tag = other.tags.create!(name: "Secret", color: "#333333")
    sign_in @user
    patch move_tag_note_path(@note), params: { from: @work.id, to: their_tag.id }
    assert_empty @note.reload.tags_for(@user) # Work removed; their tag not applied
    assert_not @note.tags.include?(their_tag)
  end

  test "the board renders draggable cards with tag-id columns" do
    sign_in @user
    get notes_path(view: "board")
    assert_select "#board[data-controller=board]"
    assert_select ".board-col[data-tag-id=?]", @work.id.to_s
    assert_select ".board-card[draggable=true]"
  end
end
