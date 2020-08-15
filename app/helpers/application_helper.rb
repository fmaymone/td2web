# frozen_string_literal: true

# Misc view helpers
module ApplicationHelper
  def current_tenant
    @current_tenant
  end

  def page_title
    return @page_title if @page_title.present?

    pt2 = params[:controller].gsub(/_controller/, '').humanize.capitalize
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
end
