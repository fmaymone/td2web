# frozen_string_literal: true

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

puts "=== Seeding Database ===\n\n"

### Default Organization
print '= Create default TCI organization...'
organization = Organization.new(
  name: 'Team Coaching International',
  slug: 'default',
  description: 'Site Administrator',
  domain: 'localhost',
  active: true
)
if organization.save
  puts 'OK'
else
  puts 'FAILED: ' + organization.errors.to_a.join(', ')
end
