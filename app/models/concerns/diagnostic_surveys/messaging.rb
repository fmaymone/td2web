# frozen_string_literal: true

module DiagnosticSurveys
  # DiagnosticSurvey Messaging logic
  module Messaging
    extend ActiveSupport::Concern

    COVER_LETTER_SUBJECT_KEY = 'team_diagnostic-cover_letter-subject'
    REMINDER_LETTER_SUBJECT_KEY = 'team_diagnostic-reminder_letter-subject'
    CANCELLATION_LETTER_SUBJECT_KEY = 'team_diagnostic-cancellation_letter-subject'

    included do
      def email
        participant.email
      end

      def send_invitation_message
        DiagnosticSurveyMailer.cover_letter(self).deliver_later
        self.delivered_at = Time.now
        save
        SystemEvent.log(event_source: self, incidental: participant, description: 'An invitiation email was sent')
      end

      def send_cancellation_message
        return false unless active?

        DiagnosticSurveyMailer.cancellation_letter(self).deliver_later
        SystemEvent.log(event_source: self, incidental: participant, description: 'A cancellation email was sent')
      end

      def send_reminder_message
        return false unless active?

        DiagnosticSurveyMailer.reminder_letter(self).deliver_later
        SystemEvent.log(event_source: self, incidental: participant, description: 'A reminder email was sent')
      end

      def template_data
        {
          team_name: team_diagnostic.name,
          participant_name: participant.full_name,
          completion_date: completed_at,
          facilitator_phone: team_diagnostic.contact_phone,
          facilitator_email: team_diagnostic.contact_email,
          facilitator_name: team_diagnostic.user.name,
          assessment_name: team_diagnostic.diagnostic.name
        }
      end

      def cover_letter_subject
        DiagnosticSurveys::Messaging::OVER_LETTER_SUBJECT_KEY.t
      rescue StandardError
        'Team Diagnostic Invitation'
      end

      def cover_letter_body
        # TODO: use TeamDiagnosticLetter
        # TODO: Improve security: strip unnecessary html tags
        # template = Liquid::Template.parse(team_diagnostic.cover_letter)
        template = Liquid::Template.parse('')
        template.render(template_data)
      end

      def reminder_letter_subject
        DiagnosticSurveys::Messaging::REMINDER_LETTER_SUBJECT_KEY.t
      rescue StandardError
        'Team Diagnostic Reminder'
      end

      def reminder_letter_body
        # TODO: use TeamDiagnosticLetter
        # TODO: Improve security: strip unnecessary html tags
        # template = Liquid::Template.parse(team_diagnostic.reminder_letter)
        template = Liquid::Template.parse('')
        template.render(template_data)
      end

      def cancellation_letter_subject
        DiagnosticSurveys::Messaging::CANCELLATION_LETTER_SUBJECT_KEY.t
      rescue StandardError
        'Team Diagnostic Was Cancelled'
      end

      def cancellation_letter_body
        # TODO: use TeamDiagnosticLetter
        # TODO: Improve security: strip unnecessary html tags
        # template = Liquid::Template.parse(team_diagnostic.cancellation_letter)
        template = Liquid::Template.parse('')
        template.render(template_data)
      end
    end
  end
end
