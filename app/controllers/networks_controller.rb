class NetworksController < ApplicationController
  before_action :set_network, only: %i[show update destroy]

  # Networks now live in Settings > Networks.
  def index
    redirect_to profile_path(tab: "networks")
  end

  def show
    authorize @network
    @memberships = @network.network_memberships.includes(:user)
    @invitations = @network.network_invitations.includes(:invited_user) if policy(@network).manage?
  end

  def create
    @network = Network.new(network_params)
    authorize @network
    if @network.save
      @network.network_memberships.create!(user: current_user, role: :admin)
      redirect_to @network, notice: "Network created."
    else
      redirect_to profile_path(tab: "networks"), alert: @network.errors.full_messages.to_sentence
    end
  end

  def update
    authorize @network
    if @network.update(network_params)
      redirect_to @network, notice: "Network updated."
    else
      @memberships = @network.network_memberships.includes(:user)
      @invitations = @network.network_invitations.includes(:invited_user)
      render :show, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @network
    @network.destroy
    redirect_to profile_path(tab: "networks"), notice: "Network deleted."
  end

  private

  def set_network
    @network = Network.find(params[:id])
  end

  def network_params
    params.require(:network).permit(:name)
  end
end
