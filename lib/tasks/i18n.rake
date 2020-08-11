# frozen_string_literal: true

namespace :i18n do
  desc 'Add translation'
  task add: :environment do |_t, args|
    xltn = nil
    Translation.transaction do
      args.extras.each do |arg|
        locale, key, value = arg.split(':').map { |a| a.chomp.strip }
        xltn = Translation.new(
          locale: locale,
          key: key,
          value: value
        )
        print "*** #{locale} translation: '#{key}' ==> '#{value}' "
        puts xltn.save! ? 'OK' : 'FAIL'
      end
    rescue ActiveRecord::ActiveRecordError => e
      puts e.message
      puts '!!! Rolling back all Translation additions.'
    end
  end

  desc 'Export View Translations to CSV'
  task export: :environment do
    require 'CSV'
    filename = ENV.fetch('FILE', 'db/seed/translations.csv')
    puts "*** Exporting translations to #{filename}..."
    File.open(filename, 'w') do |f|
      f.puts(
        TranslationServices::CsvExporter.new(filename: filename).call
      )
    end
  end

  desc 'Import View Translations from CSV'
  task import: :environment do
    filename = ENV.fetch('FILE', 'db/seed/translations.csv')
    puts "*** Import translations from #{filename}..."
    initial_count = Translation.count
    report = []
    begin
      TranslationServices::CsvImporter.new(File.read(filename)).call do |info|
        report << info
        outc = case info[:status]
               when :noop
                 '.'
               when :error
                 '!'
               when :updated
                 '~'
               when :new
                 '+'
               end
        print outc
      end
    rescue StandardError => e
      puts e.message
    end
    end_count = Translation.count
    puts
    added = report.select { |r| r[:status] == :new }
    updated = report.select { |r| r[:status] == :updated }
    errors = report.select { |r| r[:status] == :error }

    puts errors.map { |t| t[:errors] }.join(', ')
    puts "==> Added #{added.size} records === " + added.map { |t| t[:object].id }.join(', ')
    puts "==> Updated #{updated.size} records === " + updated.map { |t| t[:object].id }.join(', ')
    puts "==> Error #{errors.size} records === " + errors.map { |t| t[:object].errors.to_s }.join(', ')

    puts "==> Started with #{initial_count} Translations"
    puts "==> Ended with #{end_count} Translations"
  end
end
