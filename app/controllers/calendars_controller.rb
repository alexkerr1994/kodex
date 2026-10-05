class CalendarsController < ApplicationController
  # Per-calendar sharing page (owner only).
  def show
    @calendar = current_user.calendars.find(params[:id])
  end

  # Calendar management (create/rename/recolour/delete) from Settings > Calendars.
  def create
    @calendar = current_user.calendars.build(calendar_params)
    @calendar.color = @calendar.color.presence || Calendar.color_for(@calendar.name.to_s)
    @calendar.save
    respond_with_manager
  end

  def update
    @calendar = current_user.calendars.find(params[:id])
    @calendar.update(calendar_params)
    respond_with_manager
  end

  def destroy
    current_user.calendars.find(params[:id]).destroy
    respond_with_manager
  end

  private

  def calendar_params
    params.require(:calendar).permit(:name, :color)
  end

  def respond_with_manager
    calendars = current_user.calendars.order(:name)
    error = @calendar&.errors&.any? ? @calendar.errors.full_messages.to_sentence : nil
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace("calendars_manager", partial: "profiles/calendars_manager", locals: { calendars: calendars, error: error })
      end
      format.html { redirect_to profile_path(tab: "calendars") }
    end
  end
end
