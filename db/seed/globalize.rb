# frozen_string_literal: true

module Seeds
  # Globalize country and language data seeder
  class Globalize
    attr_reader :errors

    def initialize(filename = nil)
      @filename = filename || default_filename
      @errors = []
    end

    def call
      sql_data = File.read(@filename)
      ActiveRecord::Base.connection.execute(sql_data)
      true
    rescue StandardError => e
      @errors << e.to_s
      false
    end

    private

    def default_filename
      File.join(Rails.root, 'db', 'seed', 'tdv1_i18n_data-utf8.sql')
    end
  end
end
