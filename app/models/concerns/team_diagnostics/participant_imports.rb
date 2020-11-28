# frozen_string_literal: true

module TeamDiagnostics
  # ParticipantImports concern for TeamDiagnostic
  module ParticipantImports
    extend ActiveSupport::Concern

    included do
      has_many_attached :participant_imports
    end
  end
end
