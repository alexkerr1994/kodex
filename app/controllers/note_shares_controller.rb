class NoteSharesController < ApplicationController
  before_action :set_note

  # Share the note with a network, a person picked from your networks, or by email.
  def create
    authorize @note, :manage_sharing?
    level = params[:access_level].presence || "viewer"

    if params[:share_with].present?
      share_with_selection(params[:share_with], level)
    elsif params[:email].present?
      share_with_email(params[:email], level)
    end

    respond_with_sharing
  end

  # Remove a member's access.
  def destroy
    authorize @note, :manage_sharing?
    @note.note_memberships.find(params[:id]).destroy
    flash.now[:share_notice] = "Access removed."
    respond_with_sharing
  end

  private

  def set_note
    @note = Note.find(params[:note_id])
  end

  # Dispatch a picker selection like "network:5" or "user:12".
  def share_with_selection(token, level)
    type, id = token.split(":", 2)
    case type
    when "network"
      network = current_user.networks.find_by(id: id)
      return flash.now[:share_alert] = "Network not found." unless network

      share = @note.note_network_shares.find_or_initialize_by(network: network)
      share.access_level = level
      share.save
      flash.now[:share_notice] = "Shared with the #{network.name} network."
    when "user"
      user = network_people.find_by(id: id)
      return flash.now[:share_alert] = "That person isn't in your networks." unless user

      add_member(user, level)
    end
  end

  def share_with_email(email, level)
    user = User.find_by(email: email.to_s.strip.downcase)
    return flash.now[:share_alert] = "No user found with that email." unless user

    add_member(user, level)
  end

  # Create/update a direct membership for a specific person.
  def add_member(user, level)
    if user.id == @note.owner_id
      flash.now[:share_alert] = "They already own this note."
      return
    end

    membership = @note.note_memberships.find_or_initialize_by(user: user)
    membership.access_level = level
    if membership.save
      flash.now[:share_notice] = "Shared with #{user.display_name}."
    else
      flash.now[:share_alert] = membership.errors.full_messages.to_sentence
    end
  end

  # People who share at least one network with the current user.
  def network_people
    User.joins(:network_memberships)
        .where(network_memberships: { network_id: current_user.networks.select(:id) })
        .where.not(id: current_user.id)
        .distinct
  end

  # Re-render just the sharing pane (keeps the user on the Share tab) for Turbo,
  # or fall back to a full redirect for non-Turbo requests.
  def respond_with_sharing
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace("note_sharing", partial: "notes/sharing", locals: { note: @note })
      end
      format.html { redirect_to @note, notice: flash.now[:share_notice], alert: flash.now[:share_alert] }
    end
  end
end
