class NoteTagsController < ApplicationController
  before_action :set_note

  # Apply one of the current user's tags to this note (creating the tag if new).
  # Tagging is per-user, so anyone who can read the note may tag it.
  def create
    authorize @note, :show?

    name = params[:name].to_s.strip
    if name.present?
      tag = current_user.tags.find_or_create_by(name: name) do |t|
        t.color = params[:color].presence || Tag.color_for(name)
      end
      @note.note_tags.find_or_create_by(tag: tag) if tag.persisted?
    end

    respond_with_tags
  end

  # Remove the current user's tag from this note.
  def destroy
    authorize @note, :show?
    tag = current_user.tags.find(params[:id])
    @note.note_tags.where(tag: tag).destroy_all
    respond_with_tags
  end

  private

  def set_note
    @note = Note.find(params[:note_id])
  end

  def respond_with_tags
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace("note_tags_#{@note.id}", partial: "notes/tags_bar", locals: { note: @note })
      end
      format.html { redirect_to @note }
    end
  end
end
