# frozen_string_literal: true

# Load seed modules
Dir[File.join(__dir__, 'seed', '*.rb')].sort.each { |file| require file }

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

### Contents
#
# * Default Organization
#

puts "=== Seeding Database ===\n\n"

### Default Tenants
if (seeder = Seeds::Tenants.new).call
  puts 'OK'
else
  puts 'FAILED: ' + seeder.errors.join(', ')
end

## Default Translations
if (seeder = Seeds::Translations.new).call
  puts 'OK'
else
  puts 'FAILED: ' + seeder.errors.join(', ')
end

### Default Roles
Seeds::Roles.new.call
