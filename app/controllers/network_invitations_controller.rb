class NetworkInvitationsController < ApplicationController
  before_action :set_network

  # Admin invites someone (by email) who already has an account.
  def create
    authorize @network, :manage?
    user = User.find_by(email: params[:email].to_s.strip.downcase)

    if user.nil?
      flash[:alert] = "No account found for that email. (Inviting new people by email needs mail delivery, coming later.)"
    elsif @network.member?(user)
      flash[:alert] = "#{user.display_name} is already a member."
    else
      invitation = @network.network_invitations.build(invited_user: user, invited_by: current_user)
      flash[invitation.save ? :notice : :alert] =
        invitation.persisted? ? "Invitation sent to #{user.display_name}." : invitation.errors.full_messages.to_sentence
    end

    redirect_to @network
  end

  # Admin cancels a pending invitation.
  def destroy
    authorize @network, :manage?
    @network.network_invitations.find(params[:id]).destroy
    redirect_to @network, notice: "Invitation cancelled."
  end

  private

  def set_network
    @network = Network.find(params[:network_id])
  end
end
