# frozen_string_literal: true

module UserServices
  # User search service
  class Search
    DEFAULT_SORT = %i[username asc].freeze
    SORTS = {
      username: ->(dir) { "users.username #{dir}" },
      email: ->(dir) { "users.email #{dir}" }
    }.freeze
    MAX_PER_PAGE = 1000
    DEFAULT_PER_PAGE = 1000

    # Initialize User Search with search params, base scope, and searching user
    #
    # Example Params:
    # { user: { username: 'Jo', email: 'jo@example.com' }, paginate: true, page: 2, per_page: 25, sort_by: 'username', sort_dir: 'asc' }
    def initialize(params = {}, scope = User, user = nil)
      @skope = scope
      @user = user
      @options = sanitized_options(params)
    end

    def call
      query_scope
    end

    private

    def query_scope
      filter_by_username
      filter_by_email
      apply_sort
      apply_pagination
    end

    def filter_by_username
      @skope = @skope.where('username ilike :username', { username: "%#{@options[:user][:username]}%" }) if @options[:user][:username].present?
      @skope
    end

    def filter_by_email
      @skope = @skope.where('email ilike :email', { email: "%#{@options[:user][:email]}%" }) if @options[:user][:email].present?
      @skope
    end

    def apply_sort
      sort_opts = SORTS.fetch((@options[:sort_by] || '').to_sym, SORTS[DEFAULT_SORT[0]])
                       .call(@options.fetch(:sort_dir, DEFAULT_SORT[1]))
      @skope = @skope.order(sort_opts)
      @skope
    end

    def apply_pagination
      return @skope if @options.fetch(:paginate, 'true') != 'true'

      page = @options.fetch(:page, 1)
      per_page = [@options.fetch(:per_page, DEFAULT_PER_PAGE).to_i, MAX_PER_PAGE].min
      @skope = @skope.page(page).per(per_page)
      @skope
    end

    def sanitized_options(options = nil)
      opts = (options || {})
      opts = opts.to_unsafe_h unless opts.is_a?(Hash)
      opts[:user] ||= {}
      opts.symbolize_keys
      opts
    end
  end
end
