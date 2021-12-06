# frozen_string_literal: true

### Seeds
module Seeds
  ### extend the model to load seed dsata in yml format
  module Seedable
    extend ActiveSupport::Concern

    class_methods do
      # Example YAML data
      #
      #   ---
      #   :foobars:
      #     :version: 1
      #     :key: :name
      #     :data:
      #     - :name: foo
      #       :description: foo foo foo
      #       :active: true
      #     - :name: bar
      #       :description: bar bar bar
      #       :active: false

      def load_seed_data(yaml_path = nil)
        debug = !%w[test production].include?(Rails.env)
        klass_name = name

        yaml_path ||= "#{Rails.root}/db/seed/#{table_name}.yml"
        raise "Data not found: #{yaml_path}" unless File.exist?(yaml_path)

        msg = "SEED DATA: #{klass_name} Loading #{yaml_path}"
        Rails.logger.info msg
        puts "*** #{msg}" if debug

        seed_data = YAML.load(ERB.new(File.read(yaml_path)).result)
        data_description = seed_data.fetch(table_name.to_sym, { data: [] })
        key_attribute = data_description.fetch(:key, nil)
        data = data_description.fetch(:data)
        raise "Seed data empty: #{yaml_path}" if data.empty?

        imported = []
        noops = []
        updated = []
        errors = []

        begin
          transaction do
            data.each do |record|
              has_key_attribute = key_attribute.present?
              if has_key_attribute? && (old_record = where(*Seedable.keyed_values(record)).first).present?
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
                  msg = "SEED LOAD: Error Creating #{klass_name}['#{Seedable.keyed_values(record).to_a.join}'] : #{new_record.errors.to_a}"
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

      def keyed_values(record, key)
        case key
          when String, Symbol
            {
              key.to_sym => record.fetch(key)
            }
          when Array
            key.inject({}){|k, memo|
              memo[k] = record.fetch(k)
              memo
            }
          else
            nil
        end
      end
    end
  end
end
