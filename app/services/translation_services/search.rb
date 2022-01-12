# frozen_string_literal: true

module TranslationServices
  # Accepts a parameter Hash and returns a collection of Translation objects
  class Search
    DEFAULT_LOCALE = 'en'
    DEFAULT_ORDER = 'locale ASC, key ASC'
    VALID_PARAMS = %i[q paginate page page_size tlocale key value search order missing].freeze
    FILTER_PARAMS = %i[key value tlocale q].freeze
    DEFAULT_PARAMS = { paginate: 'false', page_size: 20 }.freeze
    REPOSITORY = ApplicationTranslation

    attr_reader :options

    def initialize(params = nil)
      @options = build_options(sanitize_search_params(params))
      @skope = REPOSITORY
    end

    # Return a collection of Translation objects
    def call
      filter_locale(@options[:tlocale])
      filter_key(@options[:key])
      filter_value(@options[:value])
      search(@options[:search])
      filter_order(@options[:order])
      paginate

      @skope
    end

    def matching_plus_missing
      collection = if @options[:missing] && @options[:tlocale]
                     missing_translations
                   else
                     call.all.to_a + missing_translations
                   end
      collection.sort_by { |t| t.key.downcase + t.locale.downcase }
    end

    def matching_plus_missing_csv
      CSV.generate do |csv|
        csv << %w[Locale Key Value]
        matching_plus_missing.each do |xtln|
          csv << [xtln.locale, xtln.key, xtln.value]
        end
      end
    end

    def missing_translations
      return [] unless @options[:tlocale]

      i18n_present_keys = call.select(:key).order('key ASC').map(&:key)
      all_keys_scope = ApplicationTranslation.select(:key).group('key').order('key ASC')
      all_keys_scope = all_keys_scope.where(key: @options[:key]) if @options[:key]
      missing_keys_scope = all_keys_scope.where('key NOT IN (?)', i18n_present_keys)
      i18n_missing_keys = missing_keys_scope.map(&:key)
      i18n_missing_keys = i18n_missing_keys.select { |k| k.match(@options[:search]) } if @options[:search]

      i18n_missing_keys.map do |key|
        ApplicationTranslation.new(
          locale: @options[:tlocale],
          key:
        )
      end
    end

    def params(new_options = {})
      @options.merge(new_options)
    end

    #     def filtered?
    #       FILTER_PARAMS.any? do |p|
    #         @options[p.to_sym].present?
    #       end
    #     end

    private

    def sanitize_search_params(params)
      in_params = params || {}
      VALID_PARAMS.each_with_object({}) do |key, memo|
        memo[key] = in_params.fetch(key, nil)
        memo
      end
    end

    def filter_locale(locale = nil)
      @skope = @skope.where(locale:) if locale
    end

    def filter_key(key = nil)
      @skope = @skope.where(key:) if key.present?
    end

    def filter_value(value = nil)
      @skope = @skope.where('value ilike :search', { search: "%#{value}%" }) if value
    end

    def search(search = nil)
      @skope = @skope.where('key ilike :search OR value ilike :search', { search: "%#{search}%" }) if search
    end

    def filter_order(order = nil)
      return @skope unless order

      col, direction = order.split('-').map(&:downcase)
      valid_filter = %w[key value locale].include?(col) && %w[asc desc].include?(direction)
      return @skope unless valid_filter

      order_param = {}
      order_param[col.to_sym] = direction
      @skope = @skope.order(order_param)
    end

    def paginate
      return unless @options[:paginate]

      @skope = @skope.page(@options[:page])
      @skope = @skope.per(@options[:page_size]) if @options[:page_size]
    end

    def build_options(params = {})
      tlocale = case (params[:tlocale] || '').downcase
                when 'all', ' ', ''
                  nil
                else
                  params[:tlocale]
                end
      {
        paginate: (params[:paginate] || DEFAULT_PARAMS[:paginate]).downcase != 'false',
        page: [(params[:page] || 1).to_i, 1].max,
        page_size: [(params[:page_size] || DEFAULT_PARAMS[:page_size]).to_i, 1].max,
        tlocale:,
        key: params[:key] || nil,
        value: params[:value] || nil,
        search: (params[:q] || '').empty? ? nil : params[:q],
        order: params[:order] || DEFAULT_ORDER,
        missing: tlocale.present? && ((params[:missing].to_s || 'false') == 'true')
      }
    end
  end
end
