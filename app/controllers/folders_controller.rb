class FoldersController < ApplicationController
  # Folder management (create/rename/delete) from the Settings > Folders tab.
  def create
    @folder = current_user.folders.create(folder_params)
    respond_with_manager
  end

  def update
    @folder = current_user.folders.find(params[:id])
    @folder.update(folder_params)
    respond_with_manager
  end

  def destroy
    current_user.folders.find(params[:id]).destroy
    respond_with_manager
  end

  private

  def folder_params
    params.require(:folder).permit(:name)
  end

  def respond_with_manager
    folders = current_user.folders.order(:name)
    error = @folder&.errors&.any? ? @folder.errors.full_messages.to_sentence : nil
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace("folders_manager", partial: "profiles/folders_manager", locals: { folders: folders, error: error })
      end
      format.html { redirect_to profile_path(tab: "folders") }
    end
  end
end
