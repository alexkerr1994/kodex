class FriendshipsController < ApplicationController
  # Send a friend request to someone by username or email.
  def create
    identifier = params[:identifier].to_s.strip.downcase
    target = User.find_by("lower(username) = :v OR lower(email) = :v", v: identifier) if identifier.present?

    return back_with(alert: "No user found with that username or email.") if target.nil?
    return back_with(alert: "That's you!") if target == current_user

    if (existing = Friendship.between(current_user, target))
      message = existing.accepted? ? "You're already friends." : "There's already a pending request with them."
      return back_with(alert: message)
    end

    Friendship.create!(requester: current_user, addressee: target, status: :pending)
    back_with(notice: "Friend request sent to #{target.display_name}.")
  end

  # Accept an incoming request addressed to the current user.
  def accept
    friendship = current_user.received_friendships.pending.find(params[:id])
    friendship.update!(status: :accepted)
    back_with(notice: "You're now friends with #{friendship.requester.display_name}.")
  end

  # Decline / cancel / unfriend — any friendship the current user is part of.
  def destroy
    friendship = Friendship.where("requester_id = :id OR addressee_id = :id", id: current_user.id).find(params[:id])
    friendship.destroy
    back_with(notice: "Done.")
  end

  private

  def back_with(**flash_opts)
    redirect_to profile_path(tab: "networks"), **flash_opts
  end
end
