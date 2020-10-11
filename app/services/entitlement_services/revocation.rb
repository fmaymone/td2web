# frozen_string_literal: true

module EntitlementServices
  # Revoke Grants
  class Revocation
    def initialize(grant:, grantor: nil)
      @grant = grant
      @grantor = grantor
    end

    def call
      @grant.active = false
      @grant.staff_notes = "#{@grant.staff_notes} #{revoke_note}"
      @grant.save
    end

    def restore
      @grant.staff_notes = "#{@grant.staff_notes} #{restore_note}"
      @grant.active = true
      @grant.save
    end

    private

    def restore_note
      format('Grant was restored at %<date>s by %<user>s.', date: DateTime.now, user: user_description)
    end

    def revoke_note
      format('Grant was revoked at %<date>s by %<user>s.', date: DateTime.now, user: user_description)
    end

    def user_description
      @grantor ? "#{@grantor.role.name}[#{@grantor.id}]" : 'System'
    end
  end
end
