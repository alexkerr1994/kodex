class NoteSharedTagsController < ApplicationController
  before_action :set_note

  # Shared tags belong to the note and are visible to everyone who can see it.
  # Only people with edit rights (or the owner/admin) may add or remove them.
  def create
    authorize @note, :update?
    name = params[:name].to_s.strip
    if name.present?
      @note.note_shared_tags.find_or_create_by(name: name) { |t| t.color = params[:color].presence || Tag.color_for(name) }
    end
    respond_with_shared_tags
  end

  def destroy
    authorize @note, :update?
    @note.note_shared_tags.find(params[:id]).destroy
    respond_with_shared_tags
  end

  private

  def set_note
    @note = Note.find(params[:note_id])
  end

  def respond_with_shared_tags
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace("note_shared_tags_#{@note.id}", partial: "notes/shared_tags_bar", locals: { note: @note })
      end
      format.html { redirect_to @note }
    end
  end
end
