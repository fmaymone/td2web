# frozen_string_literal: true

# View Helper for System Events
module SystemEventsHelper
  def severity_class(severity)
    {
      debug: 'secondary',
      info: 'info',
      warn: 'primary',
      error: 'warning',
      fatal: 'danger'
    }.fetch(severity.to_sym, 'info')
  end
end
