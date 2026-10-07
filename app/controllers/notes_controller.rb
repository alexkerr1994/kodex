class NotesController < ApplicationController
  before_action :set_note, only: %i[show update destroy toggle_task restore purge move_tag]

  # One Kanban column: a tag (or the Untagged catch-all) and its notes.
  Column = Struct.new(:name, :color, :notes, :tag_id)

  def index
    if params[:filter] == "trash"
      Note.purge_expired_trash!
      @notes = current_user.owned_notes.discarded.order(discarded_at: :desc)
      @active = :trash
      @view = :list
    else
      @notes = note_list
      @active = active_filter
      chosen_view = params[:view].presence || current_user.default_view
      @view = chosen_view == "board" ? :board : :list
      @columns = board_columns if @view == :board
    end
  end

  def show
    authorize @note
    NoteView.touch_for(current_user, @note) # mark read before building the list
    @notes = note_list # keep the middle column populated on full-page loads
    @memberships = @note.note_memberships.includes(:user)
  end

  def create
    @note = current_user.owned_notes.build(note_params.merge(last_edited_by: current_user))
    authorize @note
    if @note.save
      redirect_to @note, notice: "Note created."
    else
      redirect_to notes_path, alert: @note.errors.full_messages.to_sentence.presence || "Could not create note."
    end
  end

  def update
    authorize @note
    if @note.update(note_params.merge(last_edited_by: current_user))
      respond_to do |format|
        # Auto-save path: refresh the preview + "saved" status in place.
        format.turbo_stream { render :save }
        format.html { redirect_to @note, notice: "Note updated." }
      end
    else
      respond_to do |format|
        format.turbo_stream { render :save, status: :unprocessable_entity }
        format.html { render :show, status: :unprocessable_entity }
      end
    end
  end

  # Soft-delete: move the note to the trash (owner/admin only).
  def destroy
    authorize @note
    @note.update(discarded_at: Time.current)
    redirect_to notes_path, notice: "Moved to trash."
  end

  # Restore a note from the trash.
  def restore
    authorize @note, :destroy?
    @note.update(discarded_at: nil)
    redirect_to notes_path(filter: "trash"), notice: "Note restored."
  end

  # Permanently delete a note from the trash.
  def purge
    authorize @note, :destroy?
    @note.destroy
    redirect_to notes_path(filter: "trash"), notice: "Note permanently deleted."
  end

  # Board drag-and-drop: re-tag a note by moving its card from one tag column to
  # another (personal tags, so any reader may do it to their own tags). Removes
  # the source tag and adds the destination tag; blank = the "Untagged" column.
  def move_tag
    authorize @note, :show?
    if params[:from].present? && (from_tag = current_user.tags.find_by(id: params[:from]))
      @note.note_tags.where(tag_id: from_tag.id).destroy_all
    end
    if params[:to].present? && (to_tag = current_user.tags.find_by(id: params[:to]))
      @note.note_tags.find_or_create_by(tag: to_tag)
    end

    @columns = board_columns
    respond_to do |format|
      format.turbo_stream { render turbo_stream: turbo_stream.replace("board", partial: "notes/board", locals: { columns: @columns }) }
      format.html { redirect_to notes_path(view: "board") }
    end
  end

  # Toggle a single checklist item (the Nth `- [ ]`/`- [x]` line) from the
  # rendered preview, then re-render both the preview and the editor source.
  def toggle_task
    authorize @note, :update?
    checked = ActiveModel::Type::Boolean.new.cast(params[:checked])
    @note.update(
      body: NoteMarkdown.toggle_task(@note.body, params[:index].to_i, checked),
      last_edited_by: current_user
    )
    render :toggle_task
  end

  private

  def set_note
    @note = Note.find(params[:id])
  end

  def active_filter
    case params[:filter]
    when "favorites" then :favorites
    when "archived" then :archived
    else
      params[:tag].present? ? :tag : (params[:folder].present? ? :folder : :all)
    end
  end

  # The notes visible to the current user, newest first, optionally filtered by
  # the search box (basic title/body match — full-text search comes later).
  def note_list
    notes = policy_scope(Note).kept.order(updated_at: :desc)
            .includes(:favorites, :tags, :note_shared_tags, :note_memberships, :note_views, note_network_shares: { network: :network_memberships })
    notes = notes.where(id: current_user.favorite_notes.select(:id)) if params[:filter] == "favorites"
    if params[:tag].present? && (tag = current_user.tags.find_by(id: params[:tag]))
      notes = notes.where(id: NoteTag.where(tag_id: tag.id).select(:note_id))
    end
    if params[:folder].present? && (folder = current_user.folders.find_by(id: params[:folder]))
      notes = notes.where(id: current_user.note_filings.where(folder_id: folder.id).select(:note_id))
    end
    if params[:q].present?
      like = "%#{params[:q].strip}%"
      notes = notes.where("notes.title ILIKE :q OR notes.body ILIKE :q", q: like)
    end

    # Archived notes only show under the Archived view; excluded everywhere else.
    archived_ids = Archival.where(user_id: current_user.id).select(:note_id)
    notes = params[:filter] == "archived" ? notes.where(id: archived_ids) : notes.where.not(id: archived_ids)

    notes
  end

  # Group the user's notes by their own tags, newest column-notes first, with an
  # "Untagged" catch-all last. A note with several tags appears in each column.
  def board_columns
    notes = note_list.to_a
    columns = current_user.tags.order(:name).map do |tag|
      Column.new(tag.name, tag.color, notes.select { |n| n.tags_for(current_user).include?(tag) }, tag.id)
    end
    untagged = notes.select { |n| n.tags_for(current_user).empty? }
    columns << Column.new("Untagged", nil, untagged, nil)
    columns
  end

  def note_params
    params.require(:note).permit(:title, :body)
  end
end
