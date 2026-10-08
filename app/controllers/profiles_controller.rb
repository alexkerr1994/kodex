class ProfilesController < ApplicationController
  def show
    @user = current_user
    @tab ||= params[:tab].presence || "account"
  end

  # Profile fields (name/username/avatar on Account; theme/region on App) — both
  # submit here; `return_tab` says which tab to return to on save/error.
  def update
    @user = current_user
    @user.avatar.purge if params.dig(:user, :remove_avatar) == "1"
    tab = params[:return_tab].presence || "app"
    if @user.update(profile_params)
      redirect_to profile_path(tab: tab), notice: "Saved."
    else
      @tab = tab
      render :show, status: :unprocessable_entity
    end
  end

  # Account tab: email and/or password (requires the current password).
  def update_account
    @user = current_user
    if @user.update_with_password(account_params)
      bypass_sign_in(@user) # keep the session alive after a password change
      redirect_to profile_path(tab: "account"), notice: "Account updated."
    else
      @tab = "account"
      render :show, status: :unprocessable_entity
    end
  end

  # Referral (lives under the Account tab): email someone an invite to sign up.
  def refer
    email = params[:email].to_s.strip
    if email.match?(URI::MailTo::EMAIL_REGEXP)
      ReferralMailer.invite(current_user, email).deliver_later
      redirect_to profile_path(tab: "account"), notice: "Invite sent to #{email}."
    else
      redirect_to profile_path(tab: "account"), alert: "Please enter a valid email address."
    end
  end

  # Danger zone: permanently delete the account and everything it owns.
  def destroy
    user = current_user
    user.destroy
    reset_session
    redirect_to new_user_session_path, notice: "Your account has been deleted."
  end

  private

  def profile_params
    params.require(:user).permit(:name, :username, :theme, :time_zone, :default_view, :start_collapsed, :avatar, :holiday_region)
  end

  def account_params
    params.require(:user).permit(:email, :password, :password_confirmation, :current_password)
  end
end
