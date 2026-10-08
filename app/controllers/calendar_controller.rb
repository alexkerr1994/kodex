class CalendarController < ApplicationController
  def show
    ensure_default_calendar
    @accessible = current_user.accessible_calendars.includes(:user).order(:name).to_a
    @own_calendars = @accessible.select { |c| c.user_id == current_user.id }
    @shared_calendars = @accessible.reject { |c| c.user_id == current_user.id }

    @focus = focus_date
    @cal_view = params[:cal_view] == "week" ? :week : :month

    if @cal_view == :week
      @week_start = @focus.beginning_of_week
      @week_days = (@week_start..@week_start.end_of_week).to_a
      @events_by_day = events_by_day(@week_days.first, @week_days.last)
      @holidays = current_user.holidays_between(@week_days.first, @week_days.last)
    else
      @month = @focus.beginning_of_month
      @grid_start = @month.beginning_of_week
      @grid_end = @month.end_of_month.end_of_week
      events = accessible_events(@grid_start, @grid_end).to_a
      # Multi-day events become spanning bars; everything else stays per-day chips.
      @events_by_day = bucket_days(events.reject(&:multi_day?), @grid_start, @grid_end)
      @spans = day_spans(events.select(&:multi_day?), @grid_start, @grid_end)
      @holidays = current_user.holidays_between(@grid_start, @grid_end)
    end
  end

  private

  def focus_date
    if params[:date].present?
      Date.parse(params[:date])
    elsif params[:year].present? && params[:month].present?
      Date.new(params[:year].to_i, params[:month].to_i, 1)
    else
      Date.current
    end
  rescue ArgumentError, TypeError
    Date.current
  end

  def ensure_default_calendar
    return if current_user.calendars.exists?

    current_user.calendars.create!(name: "Personal", color: Calendar.color_for("Personal"))
  end

  # Bucket occurrences (recurrence expanded) across all accessible calendars.
  def events_by_day(from, to)
    bucket_days(accessible_events(from, to).to_a, from, to)
  end

  # Accessible events that could touch the window. Coarse SQL prefilter: an event
  # can't appear before it starts, and a bounded series can't appear after it
  # ends. Precise filtering happens in occurrence_dates; +2 days is zone slack.
  def accessible_events(from, to)
    Event.where(calendar_id: @accessible.map(&:id))
         .where("starts_at < ?", to + 2)
         .where("recurrence_until IS NULL OR recurrence_until >= ?", from)
         .includes(:calendar)
  end

  def bucket_days(events, from, to)
    buckets = Hash.new { |h, k| h[k] = [] }
    events.each do |event|
      event.occurrence_dates(from, to).each { |date| buckets[date] << event }
    end
    buckets.each_value { |list| list.sort_by! { |e| [ e.all_day? ? 0 : 1, e.starts_at ] } }
    buckets
  end

  # Multi-day events as {event:, from:, to:} with the range clipped to the grid.
  def day_spans(events, from, to)
    events.filter_map do |event|
      f = [ event.starts_at.in_time_zone.to_date, from ].max
      t = [ event.ends_at.in_time_zone.to_date, to ].min
      next if f > t

      { event: event, from: f, to: t }
    end
  end
end
