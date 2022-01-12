# frozen_string_literal: true

module EntitlementServices
  # Grant Usage Service
  class GrantUsage
    attr_reader :grant, :usage, :errors

    def initialize(user:, reference:)
      @user = user
      @reference = reference
      @errors = []
      @grant = find_grant
    end

    def call(&)
      return yield if privileged_user?

      if @grant
        if block_given? && !yield
          @errors << 'Grant unused because the referenced execution failed'
          return false
        end

        @grant.use!
        @grant.reload
      end
      @errors.empty?
    end

    def valid?
      @errors.empty? && @grant&.effective?
    end

    private

    def privileged_user?
      # TODO: remove staff (maybe?)
      @user.admin? || @user.staff?
    end

    def find_grant
      return nil if privileged_user?

      grants = @user.grants.valid
                    .where(reference: @reference)
                    .order(granted_at: :asc)
                    .select(&:effective?)
      if grants.none?
        @errors << 'User does not have any effective grants for the given reference'
        return nil
      end
      grants.first
    end
  end
end
