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
          'team_name' => team_diagnostic.name,
          'participant_name' => participant.full_name,
          'completion_date' => team_diagnostic.due_at,
          'facilitator_phone' => team_diagnostic.contact_phone,
          'facilitator_email' => team_diagnostic.contact_email,
          'facilitator_name' => team_diagnostic.user.name,
          'assessment_name' => team_diagnostic.diagnostic.name,
          'assessment_link' => format('%s://%s/diagnostic_surveys/%s', ENV.fetch('APPLICATION_PROTOCOL', 'https'), ENV.fetch('APPLICATION_HOST'), id)
        }
      end

      def letter_section(letter_type, section, locale)
        letter = team_diagnostic.team_diagnostic_letters.typed(letter_type).where(locale:).last
        unless letter
          SystemEvent.log(event_source: team_diagnostic, incidental: self,
                          description: "Missing #{letter_type} letter #{section} for #{locale}",
                          severity: :error)
          return 'Error! Please contact your facilitator'
        end

        content = case section
                  when :body, 'body'
                    letter.body
                  when :subject, 'subject'
                    letter.subject
                  end

        template = Liquid::Template.parse(content)
        template.render(template_data)
      end

      def cover_letter_subject(loc = nil)
        letter_section(:cover, :subject, loc || locale)
      end

      def cover_letter_body(loc = nil)
        letter_section(:cover, :body, loc || locale)
      end

      def reminder_letter_subject(loc = nil)
        letter_section(:reminder, :subject, loc || locale)
      end

      def reminder_letter_body(loc = nil)
        letter_section(:reminder, :body, loc || locale)
      end

      def cancellation_letter_subject(loc = nil)
        letter_section(:cancellation, :subject, loc || locale)
      end

      def cancellation_letter_body(loc = nil)
        letter_section(:cancellation, :body, loc || locale)
      end
    end
  end
end
