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
            params[:action].capitalize + ' '
          end

    "Teamdiagnostic #{pt1}#{pt2}"
  end
end
