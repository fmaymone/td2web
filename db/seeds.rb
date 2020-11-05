# frozen_string_literal: true

# Load seed modules
Dir[File.join(__dir__, 'seed', '*.rb')].sort.each { |file| require file }

def run_seeder(seeder)
  if (s = seeder.new).call
    puts 'OK'
  else
    puts "FAILED: #{s.errors.join(', ')}"
  end
end

puts "=== Seeding Database ===\n\n"
[
  # the order is meaningful
  Seeds::Tenants,
  Seeds::Translations,
  Seeds::Roles,
  Seeds::Users,
  Seeds::Entitlements
].map { |seeder| run_seeder(seeder) }

#### Default Tenants
# run_seeder(Seeds::Tenants)
# if (seeder = Seeds::Tenants.new).call
# puts 'OK'
# else
# puts "FAILED: #{seeder.errors.join(', ')}"
# end

#### Default Translations
# if (seeder = Seeds::Translations.new).call
# puts 'OK'
# else
# puts "FAILED: #{seeder.errors.join(', ')}"
# end

#### Default Roles
# Seeds::Roles.new.call

#### Default Users
# if (seeder = Seeds::Users.new).call
# puts 'OK'
# else
# puts "FAILED: #{seeder.errors.join(', ')}"
# end

#### Entitlements
# if (seeder = Seeds::Entitlements.new).call
# puts 'OK'
# else
# puts "FAILED: #{seeder.errors.join(', ')}"
# end
