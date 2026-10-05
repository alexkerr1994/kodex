class TagsController < ApplicationController
  before_action :set_tag

  def update
    error = nil
    error = @tag.errors.full_messages.to_sentence unless @tag.update(tag_params)
    respond_with_manager(error)
  end

  def destroy
    @tag.destroy
    respond_with_manager
  end

  private

  def set_tag
    @tag = current_user.tags.find(params[:id])
  end

  def tag_params
    params.require(:tag).permit(:name, :color)
  end

  def respond_with_manager(error = nil)
    tags = current_user.tags.order(:name)
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(
          "tags_manager", partial: "profiles/tags_manager", locals: { tags: tags, error: error }
        )
      end
      format.html { redirect_to profile_path }
    end
  end
end
