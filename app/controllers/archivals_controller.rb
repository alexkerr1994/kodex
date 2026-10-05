class ArchivalsController < ApplicationController
  before_action :set_note

  # Archiving is per-user, so anyone who can read the note may archive it.
  def create
    authorize @note, :show?
    current_user.archivals.find_or_create_by(note: @note)
    respond_with_archive
  end

  def destroy
    authorize @note, :show?
    current_user.archivals.where(note: @note).destroy_all
    respond_with_archive
  end

  private

  def set_note
    @note = Note.find(params[:note_id])
  end

  def respond_with_archive
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace("note_archive_#{@note.id}", partial: "notes/archive_button", locals: { note: @note })
      end
      format.html { redirect_to @note }
    end
  end
end
