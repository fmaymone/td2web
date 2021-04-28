# frozen_string_literal: true

# Load seed modules
Dir[File.join(__dir__, 'seed', '*.rb')].each { |file| require file }

### Define the set of Seeder Modules here
# NOTE: Order is important!
SEED_MODULES = [
  Seeds::Tenants,
  Seeds::Translations,
  Seeds::Roles,
  Seeds::Users,
  Seeds::Entitlements,
  Seeds::Diagnostics,
  Seeds::DiagnosticQuestions,
  Seeds::ReportTemplates
].freeze
###

puts "=== Seeding Database ===\n\n"
SEED_MODULES.map { |seeder| run_seeder(seeder) }

# Call the Seeder Module
def run_seeder(seeder)
  if (s = seeder.new).call
    puts 'OK'
  else
    puts "FAILED: #{s.errors.join(', ')}"
  end
end
