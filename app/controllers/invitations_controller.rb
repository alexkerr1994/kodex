class InvitationsController < ApplicationController
  before_action :set_invitation

  def accept
    network = @invitation.network
    network.network_memberships.find_or_create_by(user: current_user) { |m| m.role = :member }
    @invitation.destroy
    redirect_to network, notice: "You joined #{network.name}."
  end

  def decline
    name = @invitation.network.name
    @invitation.destroy
    redirect_to profile_path(tab: "networks"), notice: "Declined the invitation to #{name}."
  end

  private

  # Scoped to the current user so only the invitee can act on their invitation.
  def set_invitation
    @invitation = current_user.network_invitations.find(params[:id])
  end
end
