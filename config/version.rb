# frozen_string_literal: true

module Teamdiagnostic
  VERSION = (begin
               File.read(File.join(__dir__, 'VERSION'))
             rescue StandardError
               '0.0.0'
             end).chomp
end
