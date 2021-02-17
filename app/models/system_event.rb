# frozen_string_literal: true

# System event persistence
class SystemEvent < ApplicationRecord
  ### Constants
  SEVERITIES = %i[debug info warn error fatal unknown].freeze

  enum severity: SEVERITIES

  ### Associations
  belongs_to :event_source, polymorphic: true
  belongs_to :incidental, polymorphic: true, required: false

  def self.log(event_source:, description:, incidental: nil, debug: nil, severity: :info)
    system_event = create(
      event_source: event_source,
      incidental: incidental,
      description: description,
      debug: debug,
      severity: severity
    )

    log_message = format('SystemEvent[%s] for %s[%s] -- %s', system_event.severity, system_event.event_source_type, system_event.event_source_id, system_event.description)

    case severity
    when :debug, 0
      Rails.logger.debug log_message
    when :info, 1
      Rails.logger.info log_message
    else
      Rails.logger.warn log_message
    end

    system_event
  end
end
