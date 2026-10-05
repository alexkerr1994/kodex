# frozen_string_literal: true

class NetworkPolicy < ApplicationPolicy
  def index?
    user.present?
  end

  def create?
    user.present?
  end

  # Members (and app admins) can view a network.
  def show?
    user.admin? || record.member?(user)
  end

  # Only network admins (or app admins) manage members, invites and settings.
  def manage?
    user.admin? || record.admin?(user)
  end
  alias_method :update?, :manage?
  alias_method :destroy?, :manage?

  class Scope < Scope
    def resolve
      return scope.all if user.admin?

      scope.joins(:network_memberships).where(network_memberships: { user_id: user.id }).distinct
    end
  end
end
