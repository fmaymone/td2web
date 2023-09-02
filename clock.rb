# frozen_string_literal: true

require 'clockwork'
require './config/boot'
require './config/environment'
require 'active_support/time' # Allow numeric durations (eg: 1.minutes)

# Clockwork scheduled job definition
module Clockwork
  handler do |job, time|
    puts "Running #{job}, at #{time}"
  end

  #  every(1.minute, 'jobname') { print "Do task"}
end
