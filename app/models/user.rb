class User < ApplicationRecord
  # Public sign-up is intentionally OFF (no :registerable) — accounts are created
  # manually by an admin (see `bin/rails users:create` / console). :recoverable
  # is kept so password reset works once email is enabled.
  devise :database_authenticatable,
         :recoverable, :rememberable, :validatable

  enum :role, { member: 0, admin: 1 }

  # Selectable UI themes (see application.css). Keep in sync with the theme blocks.
  THEMES = %w[quill clean paper modern].freeze
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
    name.presence || email
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
