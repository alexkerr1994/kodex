class EventsController < ApplicationController
  before_action :set_viewable_event, only: %i[show]
  before_action :set_event, only: %i[edit update destroy]

  # Details popover (loaded into a Turbo Frame when an event is clicked).
  # Viewable for any accessible calendar; editable only if you own it.
  def show
    @editable = @event.calendar.user_id == current_user.id
    @on_date = (Date.parse(params[:date]) rescue @event.starts_at.in_time_zone.to_date)
  end

  def new
    start = default_start
    @event = current_user.events.build(
      calendar: default_calendar,
      starts_at: start,
      ends_at: default_end(start),
      # A dragged date range (?end_date=) creates an all-day multi-day event.
      all_day: params[:end_date].present?
    )
  end

  def create
    @event = build_event(event_params)
    if @event.save
      redirect_to calendar_for(@event), notice: "Event created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @event.update(event_params_with_calendar)
      redirect_to calendar_for(@event), notice: "Event updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @event.destroy
    redirect_to calendar_for(@event), notice: "Event deleted."
  end

  private

  def set_event
    @event = current_user.events.find(params[:id])
  end

  # Events on any calendar the user can see (own or shared with them).
  def set_viewable_event
    @event = Event.where(calendar_id: current_user.accessible_calendars.select(:id)).find(params[:id])
  end

  def default_calendar
    current_user.calendars.find_by(id: params[:calendar_id]) || current_user.calendars.order(:id).first
  end

  def default_start
    date = (Date.parse(params[:date]) rescue Date.current)
    # Week-view hour clicks pass ?hour= to preload that slot; default to 9am.
    hour = params[:hour].present? ? params[:hour].to_i.clamp(0, 23) : 9
    Time.zone.local(date.year, date.month, date.day, hour, 0)
  end

  # End of a dragged range (?end_date=) at the same hour; otherwise one hour on.
  def default_end(start)
    if params[:end_date].present?
      date = (Date.parse(params[:end_date]) rescue start.to_date)
      Time.zone.local(date.year, date.month, date.day, start.hour, 0)
    else
      start + 1.hour
    end
  end

  # Build an event under one of the current user's own calendars.
  def build_event(attrs)
    calendar = current_user.calendars.find(attrs[:calendar_id])
    calendar.events.build(attrs.except(:calendar_id))
  end

  def event_params
    params.require(:event).permit(:calendar_id, :title, :description, :all_day,
                                  :starts_at, :ends_at, :recurrence, :recurrence_until)
  end

  # For update: move to the chosen calendar (must be the user's) if changed.
  def event_params_with_calendar
    attrs = event_params
    calendar = current_user.calendars.find(attrs[:calendar_id])
    attrs.merge(calendar_id: calendar.id)
  end

  # Return to the month the event lives in.
  def calendar_for(event)
    d = event.starts_at&.to_date || Date.current
    calendar_path(year: d.year, month: d.month)
  end
end
