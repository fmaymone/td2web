# frozen_string_literal: true

# Test Mailer. This is a bootstrap.
class FooMailer < ApplicationMailer
  def test_email
    mail(to: 'foobar@example.com')
  end
end
