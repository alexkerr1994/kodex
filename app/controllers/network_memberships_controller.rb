class NetworkMembershipsController < ApplicationController
  before_action :set_network

  # Change a member's role (member <-> admin).
  def update
    authorize @network, :manage?
    membership = @network.network_memberships.find(params[:id])
    role = params[:role]

    if role == "member" && membership.admin? && !@network.other_admins?(membership)
      redirect_to @network, alert: "A network must keep at least one admin." and return
    end

    membership.update(role: role)
    redirect_to @network, notice: "Updated #{membership.user.display_name}."
  end

  # Remove a member from the network.
  def destroy
    authorize @network, :manage?
    membership = @network.network_memberships.find(params[:id])

    # Removing the only remaining member deletes the whole network.
    if @network.network_memberships.count <= 1
      name = @network.name
      @network.destroy
      redirect_to profile_path(tab: "networks"), notice: "#{name} was deleted — its last member was removed." and return
    end

    if membership.admin? && !@network.other_admins?(membership)
      redirect_to @network, alert: "A network must keep at least one admin." and return
    end

    membership.destroy
    redirect_to @network, notice: "Removed #{membership.user.display_name}."
  end

  # The current user leaves the network — promoting a chosen successor to admin
  # first if they're the only admin and other members remain.
  def leave
    authorize @network, :show?
    membership = @network.network_memberships.find_by(user: current_user)
    return redirect_to(profile_path(tab: "networks"), alert: "You're not a member of that network.") unless membership

    # Last member leaving deletes the network.
    if @network.network_memberships.count <= 1
      name = @network.name
      @network.destroy
      return redirect_to(profile_path(tab: "networks"), notice: "You left #{name} — it was deleted as the last member.")
    end

    # Only the SOLE admin may elect a successor, and only as part of their own
    # departure — otherwise a non-admin could promote anyone to admin.
    if membership.admin? && !@network.other_admins?(membership)
      successor = @network.network_memberships.where.not(id: membership.id).find_by(id: params[:successor_id])
      return redirect_to(@network, alert: "You're the only admin — elect another admin before leaving.") unless successor

      successor.update(role: :admin)
    end

    membership.destroy
    redirect_to profile_path(tab: "networks"), notice: "You left #{@network.name}."
  end

  private

  def set_network
    @network = Network.find(params[:network_id])
  end
end
