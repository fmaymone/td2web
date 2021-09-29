# frozen_string_literal: true

module ParticipantServices
  # Importer Class
  class Importer
    attr_reader :user, :team_diagnostic, :options, :errors, :stats, :participants, :data, :import, :rows, :header_present

    # { user: User, team_diagnostic: TeamDiagnostic, data: IO|}
    def initialize(user:, team_diagnostic:, data:, options:)
      @user = user
      @team_diagnostic = team_diagnostic
      @data = data
      @options = options
      @import = nil
      @tmpfile = @data ? @data.path : nil
      @valid = false
      @participants = []
      @errors = []
      @rows = []
      @stats = { created: 0, errors: [], skipped: 0 }
      @policy = ParticipantPolicy.new(user, Participant)
      @header_present = nil
    end

    def call
      @errors = []
      @participants = []

      unless access_granted?
        @errors << 'User does not have permission to create Participants for this TeamDiagnostic'.t
        return false
      end

      if create_import
        @participants = create_participants(parse_file(@tmpfile)) if valid?
      else
        @errors << 'No file selected'.t
      end

      valid? ? @participants : false
    end

    def valid?
      @errors.empty? && access_granted?
    end

    private

    def create_participants(participants)
      out = []
      @stats = { created: 0, errors: [], skipped: 0 }
      Participant.transaction do
        participants.each_with_index do |participant, index|
          if participant.save
            @stats[:created] += 1
            out << participant
          else
            @stats[:skipped] += 1
            @stats[:errors] << index
          end
        end
      end

      @errors << 'Failed to import any Participants'.t if participants.empty? || @stats[:skipped] == participants.size
      out
    end

    def access_granted?
      td_policy = TeamDiagnosticPolicy.new(@user, @team_diagnostic)
      participant_policy = ParticipantPolicy.new(@user, Participant)
      td_policy.update? && participant_policy.create?
    end

    def create_import
      return @import if @import
      return nil unless @data.present?

      @team_diagnostic.participant_imports.attach(@data)
      @import = @team_diagnostic.participant_imports.last
    end

    def parse_file(file)
      @participants = case content_type
                      when 'text/csv'
                        parse_csv(file)
                      when 'application/vnd.ms-excel'
                        parse_xls(file)
                      when 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
                        parse_xlsx(file)
                      else
                        @errors << '%{content_type} is not a supported file format for Participant import'.t(content_type: content_type)
                        []
                      end
    end

    def parse_csv(file)
      rows = CSV.read(file)
      @header_present = header?(rows)
      @rows = @header_present ? rows[1..] : rows
      @rows.map { |r| participant_from_row(r) }
    rescue StandardError => e
      msg = 'There was an error parsing the file'.t
      Rails.logger.error("ParticipantServices::Importer encountered an error parsing the file :: #{e}")
      @errors << msg
      []
    end

    def parse_xls(file)
      xls = Roo::Spreadsheet.open(file, extension: :xls)
      sheetname = xls.sheets[0]
      sheet = xls.sheet(sheetname)
      rows = sheet.to_a
      @header_present = header?(rows)
      @rows = @header_present ? rows[1..] : rows
      @rows.map { |r| participant_from_row(r) }
    rescue StandardError => e
      msg = 'There was an error parsing the file'.t
      Rails.logger.error("ParticipantServices::Importer encountered an error parsing the file :: #{e}")
      @errors << msg
      []
    end

    def parse_xlsx(file)
      xlsx = Roo::Spreadsheet.open(file, extension: :xlsx)
      sheetname = xlsx.sheets[0]
      sheet = xlsx.sheet(sheetname)
      rows = sheet.to_a
      @header_present = header?(rows)
      @rows = @header_present ? rows[1..] : rows
      @rows.map { |r| participant_from_row(r) }
    rescue StandardError => e
      msg = 'There was an error parsing the file'.t
      Rails.logger.error("ParticipantServices::Importer encountered an error parsing the file :: #{e}")
      @errors << msg
      []
    end

    def content_type
      return nil unless @import&.blob

      @import.blob.content_type
    end

    def participant_from_row(row)
      Participant.new(participant_attributes(row))
    end

    def header?(rows)
      data_check_ok = rows.is_a?(Array) && rows.size.positive?
      raise "Error detecting header in #{rows.class}" unless data_check_ok

      rows.first.any? { |c| c.match(/email/i) } && rows.first.all? { |c| !c.match('@') }
    end

    def participant_attributes(row)
      {
        team_diagnostic_id: @team_diagnostic.id,
        title: row[0],
        first_name: row[1],
        last_name: row[2],
        email: row[3],
        phone: row[4],
        locale: row[5] || @team_diagnostic.locale,
        timezone: row[6] || @team_diagnostic.timezone,
        metadata: row[7]
      }
    end

    def init_stats
      @stats = { created: 0, skipped: 0, errors: [] }
    end
  end
end
