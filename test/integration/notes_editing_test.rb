require "test_helper"

class NotesEditingTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @owner  = User.create!(name: "Owner", email: "owner@test.com", password: "password123")
    @editor = User.create!(name: "Editor", email: "editor@test.com", password: "password123")
    @viewer = User.create!(name: "Viewer", email: "viewer@test.com", password: "password123")
    @note = Note.create!(owner: @owner, title: "T", body: "- [ ] a\n- [ ] b\n")
    @note.note_memberships.create!(user: @editor, access_level: :editor)
    @note.note_memberships.create!(user: @viewer, access_level: :viewer)
  end

  test "editor auto-save returns a turbo stream and persists" do
    sign_in @editor
    patch note_path(@note),
          params: { note: { title: "T", body: "## New\n- [ ] a\n" } },
          headers: { "Accept" => "text/vnd.turbo-stream.html" }
    assert_response :success
    assert_match "turbo-stream", @response.body
    assert_match "note_preview", @response.body
    assert_equal "## New\n- [ ] a\n", @note.reload.body
  end

  test "saving records who made the last change and shows it in the footer" do
    sign_in @editor
    patch note_path(@note),
          params: { note: { title: "T", body: "edited" } },
          headers: { "Accept" => "text/vnd.turbo-stream.html" }
    assert_equal @editor, @note.reload.last_edited_by
    assert_match "note_last_change", @response.body
    assert_match "by #{@editor.display_name}", @response.body

    get note_path(@note)
    assert_select "#note_last_change", /Last change @ .* by #{@editor.display_name}/
  end

  test "toggling a checkbox flips the matching source line" do
    sign_in @editor
    patch toggle_task_note_path(@note),
          params: { index: 1, checked: true }.to_json,
          headers: { "Accept" => "text/vnd.turbo-stream.html", "Content-Type" => "application/json" }
    assert_response :success
    assert_equal "- [ ] a\n- [x] b\n", @note.reload.body
  end

  test "viewer cannot edit" do
    sign_in @viewer
    patch note_path(@note),
          params: { note: { body: "hacked" } },
          headers: { "Accept" => "text/vnd.turbo-stream.html" }
    assert_redirected_to notes_path
    assert_equal "- [ ] a\n- [ ] b\n", @note.reload.body
  end

  test "show page renders inline editor for editor, read-only for viewer" do
    sign_in @editor
    get note_path(@note)
    assert_select "textarea#note_body"

    sign_in @viewer
    get note_path(@note)
    assert_select "textarea#note_body", false
    assert_select ".markdown"
  end

  test "index renders the three-pane shell with sidebar and cards" do
    sign_in @owner
    get notes_path
    assert_response :success
    assert_select ".app-shell"
    assert_select ".sidebar .brand"
    assert_select ".list-col .search input"
    assert_select ".n-card", minimum: 1
    assert_select "turbo-frame#note_detail"
    assert_select ".modal[data-controller=?]", "confirm-modal" # custom confirm dialog present
  end

  test "the + button quick-creates a note and opens it" do
    sign_in @owner
    assert_difference -> { @owner.owned_notes.count }, 1 do
      post notes_path, params: { note: { title: "Untitled Note" } }
    end
    assert_redirected_to note_path(Note.last)
    assert_equal "Untitled Note", Note.last.title
  end

  test "search filters the note list by title/body" do
    sign_in @owner
    Note.create!(owner: @owner, title: "Groceries", body: "milk")
    get notes_path(q: "Grocer")
    # Cards live inside the notes_list frame, and the search form targets it (debounced live search).
    assert_select "turbo-frame#notes_list .n-card .n-title", text: "Groceries"
    assert_select ".n-card .n-title", text: "T", count: 0
    assert_select "form.search[data-turbo-frame=?][data-controller=?]", "notes_list", "search"
  end

  test "search matches are highlighted in the results" do
    sign_in @owner
    Note.create!(owner: @owner, title: "Hello world", body: "x")
    get notes_path(q: "hel")
    assert_select ".n-card .n-title mark", text: "Hel" # case-insensitive match, original casing kept
  end

  test "owner gets Edit/Preview/Share tabs; a plain editor gets no Share tab" do
    sign_in @owner
    get note_path(@note)
    assert_select ".tab[data-name=?]", "edit"
    assert_select ".tab[data-name=?]", "preview"
    assert_select ".tab[data-name=?]", "share"

    sign_in @editor
    get note_path(@note)
    assert_select ".tab[data-name=?]", "edit"
    assert_select ".tab[data-name=?]", "share", count: 0
  end

  test "sharing a note returns a turbo stream updating just the sharing pane" do
    newbie = User.create!(name: "Newbie", email: "new@test.com", password: "password123")
    sign_in @owner
    post note_shares_path(@note),
         params: { email: "new@test.com", access_level: "viewer" },
         headers: { "Accept" => "text/vnd.turbo-stream.html" }
    assert_response :success
    assert_match %r{turbo-stream action="replace" target="note_sharing"}, @response.body
    assert_includes @note.members, newbie
  end

  test "tagging a note is per-user and returns a turbo stream" do
    sign_in @viewer # even a viewer can tag notes they can see
    assert_difference -> { @viewer.tags.count }, 1 do
      post note_tags_path(@note),
           params: { name: "Reading" },
           headers: { "Accept" => "text/vnd.turbo-stream.html" }
    end
    assert_match %r{turbo-stream action="replace" target="note_tags_#{@note.id}"}, @response.body
    assert_equal [ "Reading" ], @note.tags_for(@viewer).map(&:name)
    assert_empty @note.tags_for(@owner) # the owner doesn't see the viewer's tag
  end

  test "board view groups a user's notes by their own tags plus Untagged" do
    sign_in @owner
    work = @owner.tags.create!(name: "Work", color: "#333")
    @note.note_tags.create!(tag: work)
    other = Note.create!(owner: @owner, title: "Loose", body: "x")

    get notes_path(view: :board)
    assert_response :success
    assert_select ".board-col-name", text: "Work"
    assert_select ".board-col-name", text: "Untagged"
    # tagged note appears under Work, untagged note under Untagged
    assert_select ".board-col", text: /Work.*#{@note.title}/m
    assert_select ".board-col", text: /Untagged.*#{other.title}/m
  end

  test "creating a personal tag with a chosen colour uses it" do
    sign_in @owner
    post note_tags_path(@note), params: { name: "Deep", color: "#654321" },
         headers: { "Accept" => "text/vnd.turbo-stream.html" }
    assert_equal "#654321", @owner.tags.find_by(name: "Deep").color
  end

  test "the personal tag combobox lists your unassigned tags as options" do
    sign_in @owner
    work = @owner.tags.create!(name: "Work", color: "#111111")
    home = @owner.tags.create!(name: "Home", color: "#222222")
    @note.note_tags.create!(tag: home) # already on the note -> a chip, not an option

    get note_path(@note)
    assert_select "#note_tags_#{@note.id} .tag-combo-option[data-name=?]", "Work"
    assert_select "#note_tags_#{@note.id} .tag-combo-option[data-name=?]", "Home", count: 0
  end

  test "filtering by a sidebar tag shows only notes tagged with it" do
    sign_in @owner
    work = @owner.tags.create!(name: "Work", color: "#111111")
    @note.note_tags.create!(tag: work)
    Note.create!(owner: @owner, title: "Untagged one", body: "x")

    get notes_path(tag: work.id)
    assert_response :success
    assert_select ".n-card .n-title", text: @note.title
    assert_select ".n-card .n-title", text: "Untagged one", count: 0
    assert_select ".sidebar .nav-item.active .label", text: "Work"
    assert_select ".list-title h2", text: "Work"
    assert_select ".sidebar .nav-section [data-collapsible-target=body]" # tags list wrapper present
  end

  test "cannot filter by another user's tag (filter ignored)" do
    sign_in @owner
    stranger = User.create!(email: "stranger@test.com", password: "password123")
    their_tag = stranger.tags.create!(name: "Secret", color: "#222222")
    Note.create!(owner: @owner, title: "Visible", body: "x")

    get notes_path(tag: their_tag.id)
    assert_response :success
    assert_select ".n-card .n-title", text: "Visible"
  end

  test "view toggle links between list and board" do
    sign_in @owner
    get notes_path
    assert_select ".view-toggle a[href=?]", notes_path(view: :board)
    get notes_path(view: :board)
    assert_select ".board"
    assert_select ".view-toggle a[href=?]", notes_path(view: :list)
  end
end
