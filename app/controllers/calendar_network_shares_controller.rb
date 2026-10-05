class CalendarNetworkSharesController < ApplicationController
  before_action :set_calendar

  def destroy
    @calendar.calendar_network_shares.find(params[:id]).destroy
    flash.now[:share_notice] = "Network access removed."
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace("calendar_sharing", partial: "calendars/sharing", locals: { calendar: @calendar })
      end
      format.html { redirect_to manage_calendar_path(@calendar) }
    end
  end

  private

  def set_calendar
    @calendar = current_user.calendars.find(params[:manage_calendar_id])
  end
end
