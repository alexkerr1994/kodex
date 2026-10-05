class PurgeExpiredTrashJob < ApplicationJob
  queue_as :default

  # Permanently removes trashed notes past the retention window. Scheduled daily
  # via config/recurring.yml (previously only ran lazily when viewing the trash).
  def perform
    Note.purge_expired_trash!
  end
end
