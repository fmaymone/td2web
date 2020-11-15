# frozen_string_literal: true

namespace :db do
  namespace :seed do
    desc 'Roles'
    task roles: :environment do
      require_relative '../../db/seed/roles'

      if (seeder = Seeds::Roles.new).call
        puts 'OK'
      else
        puts "FAILED: #{seeder.errors.join(', ')}"
      end
    end

    desc 'Users'
    task users: :environment do
      require_relative '../../db/seed/users'

      if (seeder = Seeds::Users.new).call
        puts 'OK'
      else
        puts "FAILED: #{seeder.errors.join(', ')}"
      end
    end

    desc 'Entitlements'
    task entitlements: :environment do
      require_relative '../../db/seed/entitlements'

      if (seeder = Seeds::Entitlements.new).call
        puts 'OK'
      else
        puts "FAILED: #{seeder.errors.join(', ')}"
      end
    end

    desc 'Diagnostics'
    task diagnostics: :environment do
      require_relative '../../db/seed/diagnostics'
      run_seeder(Seeds::Diagnostics)
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
