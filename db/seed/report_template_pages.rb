# frozen_string_literal: true

# Seed Report Templates
module Seeds
  # ReportTemplate seed data
  class ReportTemplatePages
    def self.template_id(name:, tenant: nil)
      tenant_id = (tenant || Tenant.default_tenant).id
      ReportTemplate
        .where(tenant_id:, name:, state: :published)
        .first&.id
    end

    def initialize(message: nil, filename: nil)
      @message = message || 'Load ReportTemplate Pages...'
      @filename = filename
      @errors = []
      @success = false
    end

    def call
      ReportTemplatePage.load_seed_data(@filename)
    end

    private

    def log(message)
      puts message
      Rails.logger.info message
    end
  end
end
