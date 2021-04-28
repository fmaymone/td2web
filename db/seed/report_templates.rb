# frozen_string_literal: true

# Seed Report Templates
module Seeds
  # ReportTemplate seed data
  class ReportTemplates
    DEFAULT_FILENAME_BASENAME = 'report_templates.csv'
    DEFAULT_FILENAME = File.join(Rails.root, 'db', 'seed', DEFAULT_FILENAME_BASENAME).freeze

    def initialize(message: nil, filename: DEFAULT_FILENAME)
      @message = message || 'Load ReportTemplates...'
      @errors = []
      @success = false
      @filename = filename
    end

    def call
      ReportTemplate.load_seed_csv_data(@filename) do |record|
        new_record = record.dup

        # Find the  ACTUAL Tenant
        tenant_id = Tenant.where(slug: record[:tenant_id]).first&.id
        new_record[:tenant_id] = tenant_id

        # Find the ACTUAL Diagnostic ID
        diagnostic_id = case record[:diagnostic_id].to_i
                        when 1
                          Diagnostic.where(slug: Diagnostic::TDA_SLUG).first.id
                        when 2
                          Diagnostic.where(slug: Diagnostic::TLV_SLUG).first.id
                        when 3
                          Diagnostic.where(slug: Diagnostic::T360_SLUG).first.id
                        when 4
                          Diagnostic.where(slug: Diagnostic::ORG_SLUG).first.id
                        when 5
                          Diagnostic.where(slug: Diagnostic::LEAD_360_SLUG).first.id
                        when 6
                          Diagnostic.where(slug: Diagnostic::FAMILY_TRIBES_SLUG).first.id
                        end
        new_record[:diagnostic_id] = diagnostic_id

        # Parse the JSON from the CSV string
        new_record[:template] = JSON.parse(record[:template])

        new_record
      end
    end

    private

    def log(message)
      puts message
      Rails.logger.info message
    end
  end
end
