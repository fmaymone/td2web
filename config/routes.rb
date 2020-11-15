# frozen_string_literal: true

Rails.application.routes.draw do
  root to: 'home#index'

  mount LetterOpenerWeb::Engine, at: '/letter_opener' if Rails.env.development?

  authenticated :user, ->(user) { user.admin? } do
    mount DelayedJobWeb, at: '/delayed_job'
  end

  devise_for :users, path: :auth, controllers: { sessions: 'users/sessions',
                                                 confirmations: 'users/confirmations',
                                                 registrations: 'users/registrations',
                                                 unlocks: 'users/unlocks',
                                                 passwords: 'users/passwords' }

  get 'request_consent', to: 'home#request_consent'
  post 'grant_consent', to: 'home#grant_consent'
  get 'after_registration', to: 'home#after_registration'

  resources :diagnostics do
    resources :diagnostic_questions
  end
  resources :diagnostic_questions
  resources :entitlements
  resources :invitations do
    collection do
      get 'claim', to: 'invitations#claim'
      post 'process_claim', to: 'invitations#process_claim'
    end
  end
  resources :organizations
  resources :tenants
  resources :translations, as: :application_translations, alias: :translations
  resources :users do
    resources :grants
  end
end
