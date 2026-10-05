class NoteFilingsController < ApplicationController
  # Set (or clear) the current user's folder for a note. Per-user, so anyone who
  # can read the note may file it into their own folder.
  def update
    note = Note.find(params[:note_id])
    authorize note, :show?
    filing = current_user.note_filings.find_or_initialize_by(note: note)

    if params[:new_folder].present?
      folder = current_user.folders.find_or_create_by(name: params[:new_folder].to_s.strip)
      filing.update(folder: folder) if folder.persisted?
    elsif params[:folder_id].present?
      folder = current_user.folders.find_by(id: params[:folder_id])
      filing.update(folder: folder) if folder
    else
      filing.destroy if filing.persisted?
    end

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace("note_folder_#{note.id}", partial: "notes/folder_bar", locals: { note: note })
      end
      format.html { redirect_to note }
    end
  end
end
