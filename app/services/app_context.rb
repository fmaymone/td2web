# frozen_string_literal: true

# Enumerate application endpoints
class AppContext
  BLACKLIST = [
    /^Api/,
    /^api/,
    /Devise/,
    /Users::/,
    %r{rails/conductor},
    /active_storage/,
    /^rails/,
    /action_mailbox/
  ].freeze

  class << self
    def list
      @list ||= begin
        routes = Rails.application.routes.routes
                      .map do |r|
          { controller: r.defaults[:controller],
            action: r.defaults[:action],
            verb: r.verb }
        end
        useful_routes = routes.select do |r|
          r[:controller].present? &&
            BLACKLIST.none? { |b| r[:controller].match?(b) }
        end
        controllers = useful_routes.map { |r| "#{(r[:controller] || '').camelcase}#" }.uniq.compact
        actions = useful_routes
                  .select { |r| r[:controller].present? }
                  .map { |ac| "#{ac[:controller].camelcase}##{ac[:action]}" }
        appcontexts = controllers + actions
        appcontexts.sort.uniq
      end
    end

    # List appcontexts for params containing :controller and :action keys
    def for_params(params)
      controller = params[:controller]
      action = params[:action] || ''
      return [] unless controller.present?

      list.select do |appcontext|
        req_controller = controller.camelcase
        req_action = "#{req_controller}##{action}"
        if action.present?
          req_action == appcontext ||
            "#{req_controller}#" == appcontext
        else
          appcontext.match(req_controller)
        end
      end
    end

    def accessible_to(user)
      list_policies.to_a.each_with_object({}) do |obj, memo|
        action, policy_desc = obj
        if policy_desc.present?
          policy, policy_action = policy_desc.split('#')
          policy = policy.constantize.new(user, nil)
          index_allowed = begin
            policy.index?
          rescue StandardError
            false
          end
          action_allowed = if policy_action.present?
                             begin
                               policy.send(policy_action.to_sym) || index_allowed
                             rescue StandardError
                               index_allowed
                             end
                           else
                             index_allowed
                           end
        else
          action_allowed = true
        end
        memo[action] = action_allowed || false
      end
    end

    def options_for_accessible_to(user)
      accessible_to(user).to_a
                         .select(&:last)
                         .map do |ac|
        reference = ac.first
        ac_label = humanize_context(reference)
        [ac_label, reference]
      end
    end

    def list_policies
      list.each_with_object({}) do |appcontext, memo|
        policy = policy_for_action(appcontext)
        memo[appcontext] = (policy.join('#') if policy.first)
      end
    end

    def humanize_context(context)
      controller, action = context.split('#')
      humanized_controller = (controller || '').underscore.humanize.titlecase
      humanized_action = (action || 'General').humanize.titlecase
      "#{humanized_controller}: #{humanized_action}"
    end

    def policy_for_action(reference)
      controller_name, action_name = reference.split('#')
      policy_name = "#{controller_name.underscore.singularize.camelcase}Policy"
      policy_action = nil
      if (policy = begin
        policy_name.constantize
      rescue StandardError
        nil
      end)
        policy_action_name = "#{(action_name || 'index')}?"
        policy_action = policy_action_name if policy.new(nil, nil).respond_to?(policy_action_name)
      end
      [policy, policy_action]
    end
  end
end
