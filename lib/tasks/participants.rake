namespace :participants do
  desc 'Assign Random Answers'
  task :auto_respond, [:id] => :environment do |t, args|
    participant = Participant.find(args[:id])
    exit(1) unless Rails.env.development?
    puts '--- Auto responding to participant survey'

    diagnostic_survey = participant.active_survey
    svc = DiagnosticSurveyServices::QuestionService.new(diagnostic_survey: diagnostic_survey)
    all_questions = svc.all_questions
    all_questions[0..-2].each do |q|
      svc.answer_question(question: q, response: '1')
    end
    puts 'OK'
  end
end