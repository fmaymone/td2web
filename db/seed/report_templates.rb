# frozen_string_literal: true

# Seed Report Templates
module Seeds
  # ReportTemplate seed data
  class ReportTemplates
    def initialize(filename: nil, message: nil)
      @filename = filename
      @message = message || 'Load ReportTemplates...'
      @errors = []
      @success = false
    end

    def call
      ReportTemplate.load_seed_data(@filename)
    end

    private

    def log(message)
      puts message
      Rails.logger.info message
    end
  end
end
