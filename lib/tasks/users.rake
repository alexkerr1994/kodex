namespace :users do
  desc "Create a user. EMAIL + PASSWORD required; NAME and ADMIN=true optional."
  task create: :environment do
    email = ENV.fetch("EMAIL") { abort "EMAIL is required (e.g. EMAIL=you@example.com)" }
    password = ENV.fetch("PASSWORD") { abort "PASSWORD is required" }

    user = User.create!(
      email: email,
      password: password,
      name: ENV["NAME"].presence,
      role: ENV["ADMIN"] == "true" ? :admin : :member
    )
    puts "Created #{user.role} #{user.email} (#{user.display_name})."
  rescue ActiveRecord::RecordInvalid => e
    abort "Could not create user: #{e.record.errors.full_messages.to_sentence}"
  end

  desc "Reset a user's password. EMAIL + PASSWORD required."
  task set_password: :environment do
    user = User.find_by!(email: ENV.fetch("EMAIL"))
    user.update!(password: ENV.fetch("PASSWORD"))
    puts "Password updated for #{user.email}."
  end
end
