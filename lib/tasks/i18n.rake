# frozen_string_literal: true

namespace :i18n do
  desc 'Add translation'
  task add: :environment do |_t, args|
    xltn = nil
    Translation.transaction do
      args.extras.each do |arg|
        locale, key, value = arg.split(':').map { |a| a.chomp.strip }
        xltn = Translation.new(
          locale:,
          key:,
          value:
        )
        print "*** #{locale} translation: '#{key}' ==> '#{value}' "
        puts xltn.save ? 'OK' : 'FAIL'
      end
    rescue ActiveRecord::ActiveRecordError => e
      puts e.message
      puts '!!! Rolling back all Translation additions.'
    end
  end

  desc 'Export View Translations to CSV'
  task export: :environment do
    filename = ENV.fetch('FILE', File.join(Rails.root, 'db/seed/translations.csv'))
    puts "*** Exporting translations to #{filename}..."
    File.open(filename, 'w') do |f|
      f.puts(
        TranslationServices::CsvExporter.new(filename:).call
      )
    end
  end

  desc 'Import View Translations from CSV'
  task import: :environment do
    filename = ENV.fetch('FILE', File.join(Rails.root, 'db/seed/translations.csv'))
    puts "*** Import translations from #{filename}..."
    raise "#{filename} not found!" unless File.exist?(filename)

    initial_count = Translation.count
    report = []
    begin
      TranslationServices::CsvImporter.new(File.read(filename)).call do |info|
        report << info
        outc = {
          noop: '.',
          error: '!',
          updated: '~',
          new: '+'
        }.fetch(info[:status], '?')
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

  desc 'Create Locale Select Translations'
  task generate_selects: :environment do
    GlobalizeLanguage.all.each do |gl|
      ApplicationTranslation.create(locale: 'en', key: gl.english_name, value: gl.english_name)
      next unless gl.native_name.present?

      ApplicationTranslation.create(locale: gl.iso_639_1, key: gl.english_name, value: gl.native_name)
    rescue StandardError => e
      puts "! Error: #{e}"
      puts '=> Continuing...'
      next
    end

    GlobalizeCountry.all.each do |gc|
      ApplicationTranslation.create(locale: 'en', key: gc.english_name, value: gc.english_name)
    rescue StandardError => e
      puts "! Error: #{e}"
      puts '=> Continuing...'
      next
    end
  end
end
