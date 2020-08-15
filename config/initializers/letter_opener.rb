# frozen_string_literal: true

if Rails.env.development?
  LetterOpenerWeb.configure do |config|
    config.letters_location = Rails.root.join('tmp', 'email')
  end
end
