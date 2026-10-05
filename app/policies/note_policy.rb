# frozen_string_literal: true

class NotePolicy < ApplicationPolicy
  # Any signed-in user can view their notes index and create new notes.
  def index?
    user.present?
  end

  def create?
    user.present?
  end

  # Admins can see everything; otherwise the note must be readable.
  def show?
    user.admin? || record.readable_by?(user)
  end

  # Owner or an editor-member (or admin) may change the content.
  def update?
    user.admin? || record.editable_by?(user)
  end

  # Only the owner (or an admin) may delete a note or manage its sharing.
  def destroy?
    user.admin? || record.owner_id == user.id
  end

  # Managing who a note is shared with is an owner/admin action.
  def manage_sharing?
    destroy?
  end

  class Scope < Scope
    # Which notes should appear in this user's list?
    # Owned, directly shared, or shared with a network the user belongs to.
    def resolve
      return scope.all if user.admin?

      network_ids = NetworkMembership.where(user_id: user.id).select(:network_id)
      network_note_ids = NoteNetworkShare.where(network_id: network_ids).select(:note_id)

      scope.left_joins(:note_memberships)
           .where("notes.owner_id = :id OR note_memberships.user_id = :id OR notes.id IN (:nids)",
                  id: user.id, nids: network_note_ids)
           .distinct
    end
  end
end
