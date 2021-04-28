# frozen_string_literal: true

RSpec.shared_context 'team_diagnostics', shared_context: :metadate do
  include_context 'users'
  include_context 'organizations'
  include_context 'diagnostics'

  let(:teamdiagnostic) do
    create(:team_diagnostic, user_id: facilitator.id, organization_id: organization.id, diagnostic: tda_diagnostic)
  end

  let(:completed_teamdiagnostic) do
    # Create team diagnostic
    td = create(:team_diagnostic, user_id: facilitator.id, organization_id: organization.id, diagnostic: tda_diagnostic)
    td.reload

    # Create participants
    Array.new(4) do
      ParticipantServices::Creator.new(
        user: facilitator, team_diagnostic: td, params: attributes_for(:participant, team_diagnostic: td)
      ).call
    end

    ParticipantServices::Creator.new(
      user: facilitator, team_diagnostic: td, params: attributes_for(:participant, team_diagnostic: td, locale: 'es')
    ).call

    # Assign Letters
    td.team_diagnostic_letters << td.missing_letters.map do |letter|
      letter.subject = 'foobar'
      letter.body = 'foobar'
      letter
    end
    td.save
    td.reload

    # Deploy
    td.deploy!
    td.reload
    td
  end

  let(:teamdiagnostic_ready) do
    teamdiagnostic_participants
    teamdiagnostic_letters
    teamdiagnostic.reload
    teamdiagnostic
  end

  let(:teamdiagnostic_deployed) do
    td = teamdiagnostic_ready
    td.deploy!
    td.reload
    td
  end

  let(:teamdiagnostic_completed) do
    td = teamdiagnostic_deployed
    td.auto_respond
    td.reload
    td
  end

  let(:teamdiagnostic_participants) do
    Array.new(4) do
      ParticipantServices::Creator.new(
        user: facilitator, team_diagnostic: teamdiagnostic, params: attributes_for(:participant, team_diagnostic: teamdiagnostic)
      ).call
    end
  end

  let(:teamdiagnostic_letters) do
    teamdiagnostic.team_diagnostic_letters << teamdiagnostic.missing_letters.map do |letter|
      letter.subject = 'foobar'
      letter.body = 'foobar'
      letter
    end
    teamdiagnostic.save
    teamdiagnostic.reload
    teamdiagnostic.team_diagnostic_letters
  end

  let(:teamdiagnostic_questions) do
    service = TeamDiagnosticServices::QuestionCreator.new(team_diagnostic: teamdiagnostic, user: teamdiagnostic.user)
    reference_questions = service.available_team_diagnostic_open_ended_questions
    reference_questions[0..1].each do |question|
      service2 = TeamDiagnosticServices::QuestionCreator.new(
        team_diagnostic: teamdiagnostic,
        user: teamdiagnostic.user,
        params: { diagnostic_question_id: question[:id] }
      )
      service2.call
    end
  end
end
