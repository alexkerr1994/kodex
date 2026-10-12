class NoteNetworkSharesController < ApplicationController
  before_action :set_note

  # Change a network's access level (viewer/editor).
  def update
    authorize @note, :manage_sharing?
    share = @note.note_network_shares.find(params[:id])
    share.update(access_level: params[:access_level])
    flash.now[:share_notice] = "Updated the #{share.network.name} network's access."
    respond_with_sharing
  end

  # Stop sharing a note with a network.
  def destroy
    authorize @note, :manage_sharing?
    @note.note_network_shares.find(params[:id]).destroy
    flash.now[:share_notice] = "Network access removed."
    respond_with_sharing
  end

  private

  def set_note
    @note = Note.find(params[:note_id])
  end

  def respond_with_sharing
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace("note_sharing", partial: "notes/sharing", locals: { note: @note })
      end
      format.html { redirect_to @note }
    end
  end
end
