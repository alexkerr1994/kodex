class CalendarSharesController < ApplicationController
  before_action :set_calendar

  # Share the calendar (read-only) with a network, a person from your networks, or by email.
  def create
    if params[:share_with].present?
      share_with_selection(params[:share_with])
    elsif params[:email].present?
      share_with_email(params[:email])
    end
    respond_with_sharing
  end

  def destroy
    @calendar.calendar_shares.find(params[:id]).destroy
    flash.now[:share_notice] = "Access removed."
    respond_with_sharing
  end

  private

  # Owner-only: found within the current user's own calendars.
  def set_calendar
    @calendar = current_user.calendars.find(params[:manage_calendar_id])
  end

  def share_with_selection(token)
    type, id = token.split(":", 2)
    case type
    when "network"
      network = current_user.networks.find_by(id: id)
      return flash.now[:share_alert] = "Network not found." unless network

      @calendar.calendar_network_shares.find_or_create_by(network: network)
      flash.now[:share_notice] = "Shared with the #{network.name} network."
    when "user"
      user = network_people.find_by(id: id)
      return flash.now[:share_alert] = "That person isn't in your networks." unless user

      add_share(user)
    end
  end

  def share_with_email(email)
    user = User.find_by(email: email.to_s.strip.downcase)
    return flash.now[:share_alert] = "No user found with that email." unless user

    add_share(user)
  end

  def add_share(user)
    if user.id == @calendar.user_id
      flash.now[:share_alert] = "You already own this calendar."
    else
      @calendar.calendar_shares.find_or_create_by(user: user)
      flash.now[:share_notice] = "Shared with #{user.display_name}."
    end
  end

  def network_people
    User.joins(:network_memberships)
        .where(network_memberships: { network_id: current_user.networks.select(:id) })
        .where.not(id: current_user.id).distinct
  end

  def respond_with_sharing
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace("calendar_sharing", partial: "calendars/sharing", locals: { calendar: @calendar })
      end
      format.html { redirect_to manage_calendar_path(@calendar) }
    end
  end
end
