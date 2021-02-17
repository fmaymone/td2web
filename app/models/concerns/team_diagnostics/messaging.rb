# frozen_string_literal: true

module TeamDiagnostics
  # DiagnosticSurvey Messaging logic
  module Messaging
    extend ActiveSupport::Concern

    DEPLOY_NOTIFICATION_LETTER_SUBJECT_KEY = 'team_diagnostic-deploy_notification_letter-subject'
    DEPLOY_NOTIFICATION_LETTER_BODY_KEY = 'team_diagnostic-deploy_notification_letter-subject'
    CANCEL_NOTIFICATION_LETTER_SUBJECT_KEY = 'team_diagnostic-cancel_notification_letter-subject'
    CANCEL_NOTIFICATION_LETTER_BODY_KEY = 'team_diagnostic-cancel_notification_letter-body'

    included do
      def template_data
        {
          facilitator_name: facilitator.full_name,
          assessment_name: diagnostic.name,
          team_name: name
        }
      end

      def send_deploy_notification_message
        TeamDiagnosticMailer.deploy_notification_letter(self).deliver_later
      end

      def deploy_notification_letter_subject
        TeamDiagnostics::Messaging::DEPLOY_NOTIFICATION_LETTER_SUBJECT_KEY.t
      rescue StandardError
        'Your Team Diagnostic Has Deployed!'
      end

      def deploy_notification_letter_body
        # TODO: Improve security: strip unnecessary html tags
        template = Liquid::Template.parse(TeamDiagnostics::Messaging::DEPLOY_NOTIFICATION_LETTER_BODY_KEY.t)
        template.render(template_data)
      rescue StandardError
        'Your Team Diagnostic Has Deployed!'
      end

      def send_cancel_notification_message
        TeamDiagnosticMailer.cancel_notification_letter(self).deliver_later
      end

      def cancel_notification_letter_subject
        TeamDiagnostics::Messaging::CANCEL_NOTIFICATION_LETTER_SUBJECT_KEY.t
      rescue StandardError
        'Your Team Diagnostic Has Canceled!'
      end

      def cancel_notification_letter_body
        # TODO: Improve security: strip unnecessary html tags
        template = Liquid::Template.parse(TeamDiagnostics::Messaging::CANCEL_NOTIFICATION_LETTER_BODY_KEY.t)
        template.render(template_data)
      rescue StandardError
        'Your Team Diagnostic Has Canceled!'
      end

      def send_reminders
        return false unless deployed?

        participants.active.each(&:send_reminder)
      end
    end

    class_methods do
      def self.send_reminders
        # TODO: send team diagnostic reminders
        false
        # pending_reminder.each do |diagnostic|
        # diagnostic.send_reminders
        # rescue StandardError
        ## TODO: log failure event
        # SystemEvent.log(event_source: diagnostic, description: 'Error sending reminders')
        # end
      end
    end
  end
end
