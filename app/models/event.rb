class Event < ApplicationRecord
  belongs_to :calendar
  has_one :user, through: :calendar

  # "once" = does not repeat. (Avoid the name "none" — it clashes with AR's .none.)
  enum :recurrence, { once: 0, daily: 1, weekly: 2, monthly: 3, yearly: 4 }

  validates :title, presence: true
  validates :starts_at, presence: true
  validate :ends_after_starts

  # The dates (within from..to) on which this event occurs, expanding recurrence.
  # v1: whole-series rule, no per-occurrence exceptions.
  # Each occurrence is computed from the ORIGINAL anchor (first >> n), so a
  # monthly "31st" event doesn't drift to the 28th after February. The anchor
  # uses the display zone so occurrences land on the same day they're shown.
  def occurrence_dates(from, to)
    first = starts_at.in_time_zone.to_date
    last = [ to, recurrence_until ].compact.min
    return [] if first > last
    return (first >= from ? [ first ] : []) if once?

    dates = []
    n = start_index(first, from)
    guard = 0
    loop do
      date = nth_occurrence(first, n)
      break if date > last || (guard += 1) > 600

      dates << date if date >= from && date >= first
      n += 1
    end
    dates
  end

  # A non-recurring event whose end date is after its start date — rendered as a
  # continuous spanning bar across the month grid rather than a single-day chip.
  def multi_day?
    once? && ends_at.present? && ends_at.in_time_zone.to_date > starts_at.in_time_zone.to_date
  end

  # Time-of-day parts for rendering a given occurrence date.
  def occurrence_time_label
    return nil if all_day?
    starts_at.in_time_zone.strftime("%-l:%M%P")
  end

  private

  # The nth occurrence date, always measured from the original anchor.
  def nth_occurrence(first, index)
    case recurrence
    when "daily"   then first + index
    when "weekly"  then first + (index * 7)
    when "monthly" then first >> index
    when "yearly"  then first >> (index * 12)
    else first
    end
  end

  # A starting index at/just before `from` so we don't iterate over long spans.
  # May be slightly low; the loop filters dates < from.
  def start_index(first, from)
    return 0 if from <= first

    case recurrence
    when "daily"   then (from - first).to_i
    when "weekly"  then ((from - first).to_i / 7.0).floor
    when "monthly" then (from.year * 12 + from.month) - (first.year * 12 + first.month)
    when "yearly"  then from.year - first.year
    else 0
    end
  end

  def ends_after_starts
    return if ends_at.blank? || starts_at.blank?
    errors.add(:ends_at, "must be after the start") if ends_at < starts_at
  end
end
