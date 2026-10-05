class ReferralMailer < ApplicationMailer
  # Invite a friend to sign up.
  def invite(inviter, email)
    @inviter = inviter
    @signup_url = new_user_registration_url
    mail(to: email, subject: "#{inviter.display_name} invited you to KODEX")
  end
end
