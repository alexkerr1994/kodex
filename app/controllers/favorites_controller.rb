class FavoritesController < ApplicationController
  before_action :set_note

  def create
    authorize @note, :show?
    current_user.favorites.find_or_create_by(note: @note)
    respond_with_favorite
  end

  def destroy
    authorize @note, :show?
    current_user.favorites.where(note: @note).destroy_all
    respond_with_favorite
  end

  private

  def set_note
    @note = Note.find(params[:note_id])
  end

  def respond_with_favorite
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.replace("note_favorite_#{@note.id}", partial: "notes/favorite_button", locals: { note: @note }),
          turbo_stream.replace("fav_count", partial: "notes/fav_count")
        ]
      end
      format.html { redirect_to @note }
    end
  end
end
