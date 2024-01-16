# frozen_string_literal: true

# Mailer base class
class ApplicationMailer < ActionMailer::Base
  default from: ENV.fetch('EMAIL_REPLY_TO', 'support@teamcoachinginternational.com')
  layout 'mailer'
  before_action :include_layout_images

  # private

  def include_layout_images
    attachments.inline['tci_logo.png'] = File.read(Rails.root.join('app', 'assets', 'images', 'tci_logo.png'))
  end
end
