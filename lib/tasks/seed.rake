# frozen_string_literal: true

namespace :db do
  namespace :seed do
    desc 'Roles'
    task roles: :environment do
      require_relative '../../db/seed/roles'
      run_seeder(Seeds::Roles)
    end

    desc 'Users'
    task users: :environment do
      require_relative '../../db/seed/users'
      run_seeder(Seeds::Users)
    end

    desc 'Entitlements'
    task entitlements: :environment do
      require_relative '../../db/seed/entitlements'
      run_seeder(Seeds::Entitlements)
    end

    desc 'Diagnostics'
    task diagnostics: :environment do
      require_relative '../../db/seed/diagnostics'
      run_seeder(Seeds::Diagnostics)
    end

    desc 'Diagnostic Questions'
    task diagnostic_questions: :environment do
      require_relative '../../db/seed/diagnostic_questions'
      run_seeder(Seeds::DiagnosticQuestions)
    end

    desc 'Report Templates'
    task report_templates: :environment do
      require_relative '../../db/seed/report_templates'
      run_seeder(Seeds::ReportTemplates)
    end

    desc 'Report Template Pages'
    task report_template_pages: :environment do
      require_relative '../../db/seed/report_template_pages'
      run_seeder(Seeds::ReportTemplatePages)
    end

    desc 'Products'
    task products: :environment do
      require_relative '../../db/seed/products'
      run_seeder(Seeds::Products)
    end
  end
end

# Call the Seeder Module
def run_seeder(seeder)
  if (s = seeder.new).call
    puts 'OK'
  else
    puts "FAILED: #{s.errors.join(', ')}"
  end
end
