# frozen_string_literal: true

namespace :participants do
  desc 'Assign Random Answers'
  task :auto_respond, [:id] => :environment do |_t, args|
    participant = Participant.find(args[:id])
    exit(1) unless Rails.env.development?
    puts '--- Auto responding to participant survey'

    diagnostic_survey = participant.active_survey
    svc = DiagnosticSurveyServices::QuestionService.new(diagnostic_survey:)
    all_questions = svc.all_questions
    all_questions[0..-2].each do |q|
      response = rand(1..9)
      svc.answer_question(question: q, response:)
    end
    puts 'OK'
  end
end
