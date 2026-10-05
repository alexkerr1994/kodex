class ApplicationMailer < ActionMailer::Base
  # Override in production via MAIL_FROM so the From domain matches your verified
  # sending domain (most SMTP providers require this).
  default from: ENV.fetch("MAIL_FROM", "KODEX <no-reply@kodex.app>")
  layout "mailer"
end
