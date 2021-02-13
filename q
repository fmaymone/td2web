warning: CRLF will be replaced by LF in db/seed/translations.csv.
The file will have its original line endings in your working directory
[1m[0m[1m────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────[0m
[1mmodified: app/models/concerns/team_diagnostics/letters.rb
[1m────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────[0m
[36m[1m[38;5;13m@ app/models/concerns/team_diagnostics/letters.rb:10 @[1m[1m[38;5;146m module Letters[0m
    included do[m
      has_many :team_diagnostic_letters, dependent: :destroy[m
      accepts_nested_attributes_for :team_diagnostic_letters[m
[7m[32m [m
[1m[38;5;2m[32m[m[32m      def missing_letters[m
[0m[1m[38;5;2m[32m[m[32m        all_locales = ([locale] + participants.pluck(:locale)).uniq.sort[m
[0m[1m[38;5;2m[32m[m[32m        letter_types = TeamDiagnosticLetter::LETTER_TYPES[m
[0m[1m[38;5;2m[32m[m[32m        all_combinations = [][m
[0m[1m[38;5;2m[32m[m[32m        letter_types.each{ |t| all_locales.each { |l| all_combinations << [t,l] }}[m
[0m[1m[38;5;2m[32m[m[32m        existing_combinations = team_diagnostic_letters.pluck(%i[letter_type locale])[m
[0m[1m[38;5;2m[32m[m[32m        missing_combinations = all_combinations - existing_combinations[m
[0m[1m[38;5;2m[32m[m[32m        missing_combinations.map { |mc| TeamDiagnosticLetter.default_letter(type: mc[0], locale: mc[1], team_diagnostic: self) }[m
[0m[1m[38;5;2m[32m[m[32m      end[m
[0m    end[m
  end[m
end[m
[1m[0m[1m────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────[0m
[1mmodified: app/models/team_diagnostic_letter.rb
[1m────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────[0m
[36m[1m[38;5;13m@ app/models/team_diagnostic_letter.rb:67 @[1m[1m[38;5;146m def self.default_cover_letter(locale:, team_diagnostic: nil)[0m
    )[m
  end[m
[m
[1m[38;5;2m[32m[m[32m  def self.default_cover_letter_subject(locale:)[m
[0m[1m[38;5;2m[32m[m[32m    ApplicationTranslation.where(key: "#{DEFAULT_COVER_LETTER}-subject", locale: locale).first&.value || '--'[m
[0m[1m[38;5;2m[32m[m[32m  end[m
[0m[7m[32m [m
  def self.default_reminder_letter(locale:, team_diagnostic: nil)[m
    TeamDiagnosticLetter.new([m
      team_diagnostic: team_diagnostic,[m
      letter_type: 'reminder',[m
      locale: locale,[m
[1m[38;5;1m[1;31m      subject: [m[1;31;48;5;52mApplicationTranslation.where(key: "#{DEFAULT_REMINDER_LETTER}-subject", locale: locale).first&.value || '--'[m[1;31m,[m
[0m[1m[38;5;2m[1;32m      subject: [m[1;32;48;5;22mdefault_reminder_letter_subject(locale: locale)[m[1;32m,[m
[0m      body: ApplicationTranslation.where(key: DEFAULT_REMINDER_LETTER, locale: locale).first&.value || '--'[m
    )[m
  end[m
[m
[1m[38;5;2m[32m[m[32m  def self.default_reminder_letter_subject(locale:)[m
[0m[1m[38;5;2m[32m[m[32m    ApplicationTranslation.where(key: "#{DEFAULT_REMINDER_LETTER}-subject", locale: locale).first&.value || '--'[m
[0m[1m[38;5;2m[32m[m[32m  end[m
[0m[7m[32m [m
  def self.default_cancellation_letter(locale:, team_diagnostic: nil)[m
    TeamDiagnosticLetter.new([m
      team_diagnostic: team_diagnostic,[m
      letter_type: 'cancellation',[m
      locale: locale,[m
[1m[38;5;1m[1;31m      subject: [m[1;31;48;5;52mApplicationTranslation.where(key: "#{DEFAULT_CANCELLATION_LETTER}-subject", locale: locale).first&.value || '--'[m[1;31m,[m
[0m[1m[38;5;2m[1;32m      subject: [m[1;32;48;5;22mdefault_cancellation_letter_subject(locale: locale)[m[1;32m,[m
[0m      body: ApplicationTranslation.where(key: DEFAULT_CANCELLATION_LETTER, locale: locale).first&.value || '--'[m
    )[m
  end[m
[m
[1m[38;5;2m[32m[m[32m  def self.default_cancellation_letter_subject(locale:)[m
[0m[1m[38;5;2m[32m[m[32m    ApplicationTranslation.where(key: "#{DEFAULT_CANCELLATION_LETTER}-subject", locale: locale).first&.value || '--'[m
[0m[1m[38;5;2m[32m[m[32m  end[m
[0m[7m[32m [m
  ### Instance Methods[m
end[m
[1m[0m[1m────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────[0m
[1mmodified: app/services/team_diagnostic_services/creator.rb
[1m────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────[0m
[36m[1m[38;5;13m@ app/services/team_diagnostic_services/creator.rb:73 @[1m[1m[38;5;146m def assign_defaults(team_diagnostic)[0m
      team_diagnostic.contact_phone ||= @user.user_profile&.phone_number[m
      team_diagnostic.locale ||= @user.locale[m
      team_diagnostic.timezone ||= @user.timezone[m
[7m[31m [m
[1m[38;5;1m[31m      team_diagnostic.team_diagnostic_letters <<[m
[0m[1m[38;5;1m[31m        TeamDiagnosticLetter.default_cover_letter([m
[0m[1m[38;5;1m[31m          locale: team_diagnostic.locale,[m
[0m[1m[38;5;1m[31m          team_diagnostic: team_diagnostic[m
[0m[1m[38;5;1m[31m        )[m
[0m[7m[31m [m
[1m[38;5;1m[31m      team_diagnostic.team_diagnostic_letters <<[m
[0m[1m[38;5;1m[31m        TeamDiagnosticLetter.default_reminder_letter([m
[0m[1m[38;5;1m[31m          locale: team_diagnostic.locale,[m
[0m[1m[38;5;1m[31m          team_diagnostic: team_diagnostic[m
[0m[1m[38;5;1m[31m        )[m
[0m[7m[31m [m
[1m[38;5;1m[31m      team_diagnostic.team_diagnostic_letters <<[m
[0m[1m[38;5;1m[31m        TeamDiagnosticLetter.default_cancellation_letter([m
[0m[1m[38;5;1m[31m          locale: team_diagnostic.locale,[m
[0m[1m[38;5;1m[31m          team_diagnostic: team_diagnostic[m
[0m[1m[38;5;1m[31m        )[m
[0m[7m[31m [m
[1m[38;5;2m[32m[m[32m      team_diagnostic.team_diagnostic_letters = team_diagnostic.missing_letters[m
[0m      team_diagnostic[m
    end[m
[m
[1m[0m[1m────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────[0m
[1mmodified: app/services/team_diagnostic_services/updater.rb
[1m────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────[0m
[36m[1m[38;5;13m@ app/services/team_diagnostic_services/updater.rb:111 @[1m[1m[38;5;146m def get_step(step_number = nil)[0m
[m
    def initialize_team_diagnostic[m
      @team_diagnostic = @policy_scope.where(id: @id).first or raise ActiveRecord::RecordNotFound[m
[1m[38;5;2m[32m[m[32m      @team_diagnostic.team_diagnostic_letters << @team_diagnostic.missing_letters[m
[0m[1m[38;5;2m[32m[m[32m      @team_diagnostic[m
[0m    end[m
[m
    def update_team_diagnostic[m
[1m[0m[1m────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────[0m
[1mmodified: db/seed/translations.csv
[1m────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────[0m
[36m[1m[38;5;13m@ db/seed/translations.csv:12330 @[1m[1m[38;5;146m en,team_diagnostic-deploy_notification_letter-body,"Hello {{facilitator_name}},[0m
Your {{assessment_name}} for {{team_name}} has been deployed. The participants for this diagnostic are now being sent their invitations.[m
[m
Thank you!"[m
[1m[38;5;2m[32m[m[32men,What,What[m
[0m[1m[38;5;2m[32m[m[32men,What's your favorite color?,What's your favorite color?[m
[0m[1m[38;5;2m[32m[m[32men,Help,Help[m
[0m[1m[38;5;2m[32m[m[32men,Subject,Subject[m
[0m[1m[38;5;2m[32m[m[32men,template-teamdiagnostic-cover-letter-subject,PLACEHOLDER[m
[0m[1m[38;5;2m[32m[m[32men,template-teamdiagnostic-reminder-letter-subject,PLACEHOLDER[m
[0m[1m[38;5;2m[32m[m[32men,template-teamdiagnostic-cancellation-letter-subject,PLACEHOLDER[m
[0m