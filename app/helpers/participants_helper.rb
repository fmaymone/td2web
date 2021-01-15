# frozen_string_literal: true

# Participant view helpers
module ParticipantsHelper
  def participant_state_badge_class(participant)
    if participant.needs_attention?
      'warning'
    else
      {
        'approved' => 'info',
        'active' => 'success',
        'disqualified' => 'danger'
      }.fetch('participant_state', 'info')
    end
  end
end
