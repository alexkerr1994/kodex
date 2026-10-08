class User < ApplicationRecord
  # Public sign-up is intentionally OFF (no :registerable) — accounts are created
  # manually by an admin (see `bin/rails users:create` / console). :recoverable
  # is kept so password reset works once email is enabled.
  devise :database_authenticatable,
         :recoverable, :rememberable, :validatable

  enum :role, { member: 0, admin: 1 }

  # Virtual field for sign-in: accepts a username OR an email.
  attr_accessor :login

  # Usernames are stored lowercase + trimmed so uniqueness is simple and stable.
  normalizes :username, with: ->(value) { value.to_s.strip.downcase }

  validates :username, presence: true,
                       uniqueness: { case_sensitive: false },
                       length: { maximum: 50 },
                       format: { with: /\A[a-z0-9._-]+\z/,
                                 message: "can only contain letters, numbers, dots, underscores, and hyphens" }

  # New accounts default their username to the email local-part if none was given.
  before_validation :ensure_username, on: :create

  # Let users sign in with either their username or their email.
  def self.find_for_database_authentication(warden_conditions)
    conditions = warden_conditions.dup
    if (login = conditions.delete(:login))
      where(conditions.to_h)
        .where("lower(username) = :value OR lower(email) = :value", value: login.to_s.downcase)
        .first
    else
      where(conditions.to_h).first
    end
  end

  # Selectable UI themes (see application.css). Keep in sync with the theme blocks.
  THEMES = %w[quill clean paper modern tron].freeze
  DEFAULT_VIEWS = %w[list board].freeze
  # Public-holiday regions offered in settings (code → label), backed by the
  # `holidays` gem. Blank = no holiday overlay. Curated subset of common regions.
  HOLIDAY_REGIONS = {
    "my" => "Malaysia", "sg" => "Singapore", "fr" => "France", "gb" => "United Kingdom",
    "us" => "United States", "ca" => "Canada", "au" => "Australia", "nz" => "New Zealand",
    "de" => "Germany", "es" => "Spain", "it" => "Italy", "nl" => "Netherlands",
    "be" => "Belgium", "ch" => "Switzerland", "at" => "Austria", "ie" => "Ireland",
    "pt" => "Portugal", "se" => "Sweden", "no" => "Norway", "dk" => "Denmark",
    "jp" => "Japan", "in" => "India", "br" => "Brazil", "za" => "South Africa"
  }.freeze
  validates :theme, inclusion: { in: THEMES }
  validates :default_view, inclusion: { in: DEFAULT_VIEWS }
  validates :time_zone, inclusion: { in: ActiveSupport::TimeZone.all.map(&:name) }, allow_blank: true
  validates :holiday_region, inclusion: { in: HOLIDAY_REGIONS.keys }, allow_blank: true

  has_one_attached :avatar
  validate :avatar_must_be_an_image

  private

  def avatar_must_be_an_image
    return unless avatar.attached?
    return if avatar.content_type.in?(%w[image/png image/jpeg image/webp])

    errors.add(:avatar, "must be a PNG, JPEG, or WEBP image")
  end

  # Derive a unique username from the email local-part when none was provided.
  def ensure_username
    return if username.present?

    base = email.to_s.split("@").first.to_s.downcase.gsub(/[^a-z0-9._-]/, "")
    base = "user" if base.blank?
    candidate = base
    n = 1
    while self.class.where.not(id: id).exists?(username: candidate)
      candidate = "#{base}#{n}"
      n += 1
    end
    self.username = candidate
  end

  public

  # Notes this user owns outright (full control, no membership row needed).
  has_many :owned_notes, class_name: "Note", foreign_key: :owner_id, dependent: :destroy

  # Notes explicitly shared with this user via a membership.
  has_many :note_memberships, dependent: :destroy
  has_many :shared_notes, through: :note_memberships, source: :note

  # This user's personal tags (tags are per-user).
  has_many :tags, dependent: :destroy

  # Per-note "last viewed" timestamps backing the unread indicator.
  has_many :note_views, dependent: :destroy

  # Personal folders + how this user has filed notes into them.
  has_many :folders, dependent: :destroy
  has_many :note_filings, dependent: :destroy

  # Calendars + events.
  has_many :calendars, dependent: :destroy
  has_many :events, through: :calendars
  has_many :calendar_shares, dependent: :destroy

  # Calendars this user can see: their own + ones shared directly + ones shared
  # with a network they belong to (all read-only overlay for shared ones).
  def accessible_calendars
    direct = CalendarShare.where(user_id: id).select(:calendar_id)
    via_network = CalendarNetworkShare
                    .where(network_id: NetworkMembership.where(user_id: id).select(:network_id))
                    .select(:calendar_id)
    Calendar.where(user_id: id).or(Calendar.where(id: direct)).or(Calendar.where(id: via_network))
  end

  # Notes this user has favourited (per-user).
  has_many :favorites, dependent: :destroy
  has_many :favorite_notes, through: :favorites, source: :note

  # Notes this user has archived (per-user; kept forever until unarchived).
  has_many :archivals, dependent: :destroy
  has_many :archived_notes, through: :archivals, source: :note

  # Networks (groups) this user belongs to.
  has_many :network_memberships, dependent: :destroy
  has_many :networks, through: :network_memberships
  # Pending invitations addressed to this user.
  has_many :network_invitations, foreign_key: :invited_user_id, dependent: :destroy, inverse_of: :invited_user

  # All notes this user can access (owned + shared), as a single relation.
  def accessible_notes
    Note.where(owner_id: id).or(Note.where(id: note_memberships.select(:note_id)))
  end

  def display_name
    name.presence || username
  end

  # Lightweight "friends" = people this user already collaborates with:
  # co-members of their networks, people they've shared notes with, and owners of
  # notes shared with them. Distinct, excludes self.
  def friends
    ids = NetworkMembership.where(network_id: network_memberships.select(:network_id)).distinct.pluck(:user_id)
    ids += Note.where(id: note_memberships.select(:note_id)).distinct.pluck(:owner_id)
    ids += NoteMembership.where(note_id: owned_notes.select(:id)).distinct.pluck(:user_id)
    User.where(id: ids.uniq - [ id ]).order(:name)
  end

  # Public holidays for this user's chosen region within a date window, as
  # { Date => "Holiday name" }. Empty when no region is selected.
  def holidays_between(from, to)
    return {} if holiday_region.blank?

    Holidays.between(from.to_date, to.to_date, holiday_region.to_sym)
            .each_with_object({}) { |h, acc| acc[h[:date]] ||= h[:name] }
  rescue Holidays::InvalidRegion
    {}
  end
end
