# frozen_string_literal: true

namespace :db do
  namespace :seed do
    desc 'Roles'
    task roles: :environment do
      Role.load_seed_data
    end
  end
end
