# frozen_string_literal: true

namespace :db do
  namespace :seed do
    desc 'Roles'
    task roles: :environment do
      Role.load_seed_data
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
  end
end
