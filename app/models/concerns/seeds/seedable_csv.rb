# frozen_string_literal: true

### Seeds
module Seeds
  ### extend the model to load seed dsata in yml format
  module SeedableCsv
    extend ActiveSupport::Concern

    class_methods do
      def load_seed_csv_data(csv_path = nil)
        debug = !%w[test production].include?(Rails.env)
        klass_name = name

        csv_path ||= "#{Rails.root}/db/seed/#{table_name}.csv"
        raise "Data not found: #{csv_path}" unless File.exist?(csv_path)

        msg = "SEED DATA: #{klass_name} Loading #{csv_path}"
        Rails.logger.info msg
        puts "*** #{msg}" if debug

        seed_data = CSV.read(csv_path) || []
        header_row = seed_data[0]
        raise "Seed data empty: #{csv_path}" if header_row.nil?

        data = seed_data[1..].map do |row|
          record = {}
          header_row.each_with_index do |col, index|
            record[col.to_sym] = row[index]
          end
          record
        end
        raise "Seed data empty: #{csv_path}" if data.empty?

        key_attribute = header_row[0].to_sym
        imported = []
        noops = []
        updated = []
        errors = []

        begin
          transaction do
            data.each do |record|
              record = yield(record) if block_given?
              if (old_record = where(key_attribute => record.fetch(key_attribute)).first).present?
                old_record.attributes = record
                data_changed = old_record.changed?
                if old_record.save
                  if data_changed
                    msg = "SEED LOAD: Updated #{klass_name}[#{old_record.id}] : #{old_record.previous_changes}"
                    Rails.logger.info msg
                    puts "*** #{msg}" if debug
                    updated << { id: old_record.id, changes: old_record.previous_changes }
                  else
                    msg = "SEED LOAD: No Change #{klass_name}[#{old_record.id}]"
                    Rails.logger.info msg
                    puts "*** #{msg}" if debug
                    noops << { id: old_record.id }
                  end
                else
                  msg = "SEED LOAD: Error Updating #{klass_name}[#{old_record.id}] : #{old_record.errors.to_a}"
                  Rails.logger.info msg
                  puts "*** #{msg}" if debug
                  errors << { id: old_record.id, errors: old_record.errors.to_a }
                end
              else
                new_record = new(record)
                if new_record.save
                  msg =  "SEED LOAD: Created #{klass_name}[#{new_record.id}] : #{record}"
                  Rails.logger.info msg
                  puts "*** #{msg}" if debug
                  imported << { id: new_record.id, changes: new_record.previous_changes }
                else
                  msg = "SEED LOAD: Error Creating #{klass_name}['#{record[key_attribute]}'] : #{new_record.errors.to_a}"
                  Rails.logger.info msg
                  puts "*** #{msg}" if debug
                  errors << { id: nil, errors: new_record.errors.to_a }
                end
              end
            end
          end
          msgs = [
            "SEED LOAD: Noop (#{noops.size}) #{noops.join('  ')}",
            "SEED LOAD: Imported(#{imported.size}) #{imported.join('  ')}",
            "SEED LOAD: Errors(#{errors.size}) #{errors.join('  ')}",
            "SEED LOAD: Updated(#{updated.size}) #{updated.join('  ')}"
          ]
          msgs.each do |m|
            puts "*** #{m}" if debug
            Rails.logger.info msg
          end
          true
        rescue StandardError => e
          msg = "SEED LOAD FAILED! Rolled back updates. Error: #{e} #{e.backtrace}"
          Rails.logger.info msg
          puts "*** #{msg}" if debug
          false
        end
      end
    end
  end
end
