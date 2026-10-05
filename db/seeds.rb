# Recreates the sharing scenario from the app spec.
# Run with: bin/rails db:seed  (safe to re-run — it clears existing data first)

Favorite.delete_all
NoteTag.delete_all
Tag.delete_all
NoteMembership.delete_all
Note.delete_all
User.delete_all

password = "password123"

alice = User.create!(name: "Alice (A)", email: "a@example.com", password: password)
bob   = User.create!(name: "Bob (B)",   email: "b@example.com", password: password)
carol = User.create!(name: "Carol (C)", email: "c@example.com", password: password)

# A dedicated admin to demo the global override (sees & manages every note).
User.create!(name: "Admin", email: "admin@example.com", password: password, role: :admin)

# Note #1 — owned by A, private to A.
Note.create!(owner: alice, title: "Note #1 — Alice private", body: <<~MD)
  # Private thoughts

  Only Alice can see this. Markdown works here — **bold**, _italic_, and `code`.

  > Even blockquotes.
MD

# Note #2 — owned by A, shared with B and C.
note2 = Note.create!(owner: alice, title: "Note #2 — shared with everyone", body: <<~MD)
  ## Project checklist

  Alice owns this; Bob can edit, Carol can only view.

  - [x] Set up the repo
  - [x] Add authentication
  - [ ] Write the docs
  - [ ] Ship it

  | Task | Owner |
  | ---- | ----- |
  | Docs | Bob   |
  | QA   | Carol |
MD
note2.note_memberships.create!(user: bob,   access_level: :editor)
note2.note_memberships.create!(user: carol, access_level: :viewer)

# Note #3 — owned by C, shared with B only.
note3 = Note.create!(owner: carol, title: "Note #3 — Carol & Bob", body: <<~MD)
  ## Shopping

  Carol owns this and shared it with Bob only.

  - [ ] Milk
  - [ ] Bass strings
  - [x] Coffee
MD
note3.note_memberships.create!(user: bob, access_level: :viewer)

# Attribute the initial version of each note to its owner.
Note.find_each { |n| n.update_column(:last_edited_by_id, n.owner_id) }

# A couple of favourites so the Favorites filter isn't empty.
alice.favorites.create!(note: note2)
bob.favorites.create!(note: note3)

# Per-user tags, so the Kanban board (grouped by *your* tags) has columns.
note1 = alice.owned_notes.find_by(title: "Note #1 — Alice private")
def tag!(user, note, name)
  tag = user.tags.find_or_create_by!(name: name) { |t| t.color = Tag.color_for(name) }
  note.note_tags.find_or_create_by!(tag: tag)
end
tag!(alice, note1, "Personal")
tag!(alice, note2, "Work")
tag!(bob,   note2, "Todo")        # Bob's own tag on the shared note
tag!(carol, note2, "Work")        # Carol tags the same note with her own "Work"
tag!(carol, note3, "Shopping")

puts "Seeded #{User.count} users, #{Note.count} notes, #{Tag.count} tags."
puts "Log in with a@example.com / b@example.com / c@example.com — password: #{password}"
