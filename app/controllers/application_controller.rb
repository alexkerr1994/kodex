class ApplicationController < ActionController::Base
  include Pundit::Authorization

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  before_action :authenticate_user!, unless: :devise_controller?
  around_action :use_time_zone

  # Devise (auth) pages get their own full-screen dark layout.
  layout :resolve_layout

  # Send users somewhere sensible when they hit a page they can't access.
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  private

  def resolve_layout
    devise_controller? ? "auth" : "application"
  end

  # Render times in the signed-in user's chosen timezone (falls back to the app default).
  def use_time_zone(&block)
    zone = current_user&.time_zone.presence || Time.zone
    Time.use_zone(zone, &block)
  end

  def user_not_authorized
    redirect_to(notes_path, alert: "You are not authorized to do that.")
  end
end
