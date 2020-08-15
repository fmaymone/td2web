# frozen_string_literal: true

module Users
  # User model class extension for Devise authentication
  module Devise
    extend ActiveSupport::Concern

    included do
      devise :database_authenticatable, :async, :registerable, :recoverable, :rememberable, :validatable, :confirmable, :lockable, :trackable
    end

    attr_accessor :login

    class_methods do
    end
  end
end
