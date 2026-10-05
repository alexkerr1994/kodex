class NoteNetworkSharesController < ApplicationController
  before_action :set_note

  # Stop sharing a note with a network.
  def destroy
    authorize @note, :manage_sharing?
    @note.note_network_shares.find(params[:id]).destroy
    flash.now[:share_notice] = "Network access removed."

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace("note_sharing", partial: "notes/sharing", locals: { note: @note })
      end
      format.html { redirect_to @note }
    end
  end

  private

  def set_note
    @note = Note.find(params[:note_id])
  end
end
