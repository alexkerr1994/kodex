class Note < ApplicationRecord
  belongs_to :owner, class_name: "User"
  belongs_to :last_edited_by, class_name: "User", optional: true

  has_many :note_memberships, dependent: :destroy
  has_many :members, through: :note_memberships, source: :user

  # Notes can also be shared with whole networks (access stays live as the
  # network's membership changes).
  has_many :note_network_shares, dependent: :destroy
  has_many :shared_networks, through: :note_network_shares, source: :network

  # Personal tags (per-user) via note_tags; shared tags belong to the note and
  # are visible to everyone who can see it (managed by editors/owner).
  has_many :note_tags, dependent: :destroy
  has_many :tags, through: :note_tags
  has_many :note_shared_tags, dependent: :destroy

  has_many :favorites, dependent: :destroy
  has_many :note_filings, dependent: :destroy
  has_many :archivals, dependent: :destroy

  # Per-user "last looked at" timestamps, for the unread indicator.
  has_many :note_views, dependent: :destroy

  validates :title, presence: true

  # Soft-delete (trash) support.
  TRASH_RETENTION = 30.days
  scope :kept, -> { where(discarded_at: nil) }
  scope :discarded, -> { where.not(discarded_at: nil) }

  # Permanently remove notes that have sat in the trash past the retention window.
  def self.purge_expired_trash!
    discarded.where(discarded_at: ..TRASH_RETENTION.ago).destroy_all
  end

  def discarded?
    discarded_at.present?
  end

  def favorited_by?(user)
    favorites.any? { |f| f.user_id == user.id }
  end

  def archived_by?(user)
    archivals.any? { |a| a.user_id == user.id }
  end

  # The folder this user has filed the note in (per-user), or nil.
  def folder_for(user)
    note_filings.find { |f| f.user_id == user.id }&.folder
  end

  # Tags a specific user has applied to this note (tags are per-user).
  def tags_for(user)
    tags.select { |t| t.user_id == user.id }
  end

  # --- Access helpers -------------------------------------------------------
  # The owner always has full control. Other users need a membership row.

  # Uses the loaded association (preloaded on the notes list) to avoid a query per note.
  def membership_for(user)
    note_memberships.find { |m| m.user_id == user.id }
  end

  # Can the user at least view this note?
  def readable_by?(user)
    owner_id == user.id ||
      member_ids.include?(user.id) ||
      note_network_shares.any? { |s| s.network.member?(user) }
  end

  # Has someone else changed this note since the user last looked at it?
  # Your own edits never count as unread. A note you can access but have never
  # opened reads as unread so it draws attention. Uses the loaded association
  # (preloaded on the notes list) to stay query-free per card.
  def unread_for?(user)
    return false if owner_id == user.id && last_edited_by_id.nil?
    return false if last_edited_by_id == user.id

    view = note_views.find { |v| v.user_id == user.id }
    view.nil? || updated_at > view.last_viewed_at
  end

  # Can the user edit the note's content?
  def editable_by?(user)
    owner_id == user.id ||
      membership_for(user)&.editor? ||
      note_network_shares.any? { |s| s.editor? && s.network.member?(user) }
  end
end
