# frozen_string_literal: true

# Devise Mailer class
class DeviseMailer < Devise::Mailer
  before_action :include_layout_images

  def include_layout_images
    attachments.inline['tci_logo.png'] = File.read(Rails.root.join('app', 'assets', 'images', 'tci_logo.png'))
  end
end
