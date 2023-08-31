# frozen_string_literal: true

# Misc view helpers
module ApplicationHelper
  def current_tenant
    @current_tenant
  end

  def show_login_link?
    no_login_controllers = %w[sessions diagnostic_surveys]
    !user_signed_in? && !no_login_controllers.include?(controller.controller_name)
  end

  def page_title
    return @page_title if @page_title.present?

    pt2 = params[:controller].gsub('_controller', '').humanize.capitalize
    action = params[:action].downcase
    pt1 = case action
          when 'index'
            'List '
          else
            "#{params[:action].capitalize} "
          end

    "Teamdiagnostic #{pt1}#{pt2}"
  end

  def flash_alert_class(type)
    {
      'alert' => 'alert-danger',
      'notice' => 'alert-success',
      'info' => 'alert-info',
      'error' => 'alert-danger',
      'danger' => 'alert-danger'
    }.fetch(type, '')
  end

  def short_date(date)
    date.to_s('%F')
  end

  def input_validation_class(object, field)
    return '' unless defined?(@show_validation_messages) && @show_validation_messages

    err = object.errors.to_h.fetch(field.to_s, nil)
    err.present? ? ' is-invalid' : ''
  end

  def input_validation_feedback(object, field)
    return '' unless defined?(@show_validation_messages) && @show_validation_messages

    err = object.errors.to_h.fetch(field.to_s, nil)
    feedbackid = "#{object.class}--#{field}--Feedback"
    if err.present?
      content_tag(:div, id: feedbackid, class: 'invalid-feedback') do
        err
      end
    else
      content_tag(:div, id: feedbackid, class: 'valid-feedback') do
        # noop
      end
    end
  end

  def active_badge(active, pill: false)
    html_classes = %w[badge]
    html_classes << (active ? 'badge-success' : 'badge-secondary')
    html_classes << 'badge-pill' if pill
    html_classes = html_classes.join(' ')
    content_tag(:span, class: html_classes) do
      active ? 'Active'.t : 'Inactive'.t
    end
  end

  def account_limited(limited, pill: false)
    html_classes = %w[badge]
    html_classes << (limited ? 'badge-success' : 'badge-secondary')
    html_classes << 'badge-pill' if pill
    html_classes = html_classes.join(' ')
    content_tag(:span, class: html_classes) do
      limited ? 'Limited'.t : 'Unregistered'.t
    end
  end

  def i18n_date_long(date)
    return '' unless date.present?

    if @current_locale == 'en'
      I18n.l(date, format: '%B %e, %Y %l:%M %p', locale: @current_locale)
    else
      I18n.l(date, format: :long, locale: @current_locale)
    end
  end

  def sanitized_translation(key)
    whitelisted = %w[ul li p b i h2 h3 strong small br hr]
    sanitize key.t, tags: whitelisted
  end

  def nav_item_class(key, action = nil)
    nav_item_active?(key, action) ? 'active' : ''
  end

  def nav_item_active?(key, action = nil)
    params[:controller] == key.to_s && (action ? params[:action] == action.to_s : true)
  end

  def severity_class(severity)
    s = severity.to_sym
    case s
    when :debug
      'light'
    when :info
      'info'
    when :warn
      'warning'
    when :error, :fatal
      'danger'
    else
      'secondary'
    end
  end
end
