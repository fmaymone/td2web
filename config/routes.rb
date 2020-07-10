# frozen_string_literal: true

Rails.application.routes.draw do
  root to: 'home#index'

  resources :translations, as: :application_translations, alias: :translations
  resources :organizations
end
