# frozen_string_literal: true

module EntitlementServices
  # Helper Class for creating Entitlement Invitations
  class InvitationCreator
    PERMITTED_PARAMS = [:email, :description, :i18n_key, { entitlements: [] }].freeze

    attr_reader :invitation, :grantor, :params, :errors

    # Init Service
    #
    # params: {
    #   invitation: {
    #     entitlements: [ (required)
    #       {
    #         id: UUID,
    #         quota: Integer
    #       },
    #     ],
    #     email: String (required),
    #     description: String,
    #     i18n_key: String (required)
    #   }
    # }
    # grantor: User | ???Order???
    def initialize(grantor:, params: {})
      @params = sanitize_params(params)
      @grantor = grantor
      @invitation = Invitation.new(@params)
      @invitation.grantor = @grantor
      @invitation.tenant = @grantor.tenant
      @errors = []
    end

    def call
      if @invitation.save
        send_invitation
      else
        @errors = @invitation.errors.full_messages
      end
      @invitation
    end

    def success?
      @errors.none?
    end

    def entitlement_options
      Entitlement.active
                 .where(role_id: grantor_role_ids)
                 .order(slug: :asc)
                 .map do |entitlement|
        selected = selected_entitlement(entitlement.id)
        {
          id: entitlement.id,
          slug: entitlement.slug,
          name: format('%<description>s (%<slug>s)', description: entitlement.description, slug: entitlement.slug),
          quota: (selected&.fetch('quota') || entitlement.quota),
          selected: selected_entitlement(entitlement.id).present?
        }
      end
    end

    def selected_entitlement(id)
      (invitation.entitlements || []).select do |e|
        e['id'] == id
      end.first
    end

    def i18n_key_options
      if (e_options = entitlement_options).any?
        ApplicationTranslation.where(key: e_options.map { |entitlement| "#{Invitation::I18N_KEY_BASE}-#{entitlement[:slug]}" }).pluck(:key)
      else
        ApplicationTranslation.where("key ilike '#{Invitation::I18N_KEY_BASE}-%'").order(key: :asc).pluck(:key)
      end
    end

    private

    def grantor_role_ids
      case @grantor
      when User
        grantor_role = @grantor.role
        Role.all.select { |role| grantor_role >= role }
      else
        Role.facilitator
      end.map(&:id)
    end

    def send_invitation
      InvitationMailer.entitlement_invitation(@invitation).deliver_later
    end

    def sanitize_params(params)
      if params.is_a?(ActionController::Parameters)
        data = params.require('invitation').permit!.to_unsafe_h if params[:invitation].present?
      else
        data = params
      end

      {
        email: data[:email],
        description: data[:description],
        i18n_key: data[:i18n_key],
        entitlements: normalized_entitlements(data[:entitlements]),
        redirect: data[:redirect]
      }
    end

    def normalized_entitlements(entitlements)
      (entitlements || []).map do |entitlement|
        next unless entitlement[:id].present?

        {
          id: entitlement[:id],
          quota: entitlement[:quota]
        }
      end.compact
    end
  end
end
