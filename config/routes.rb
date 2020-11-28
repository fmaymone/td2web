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
  resources :team_diagnostics do
    resources :participants do
      collection do
        get :define_import, to: 'participants#define_import'
        post :create_import, to: 'participants#create_import'
      end
      member do
        post :disqualify, to: 'participants#disqualify'
        post :restore, to: 'participants#restore'
      end
    end
    member do
      get 'wizard/:step', to: 'team_diagnostics#wizard', as: 'wizard'
      post :deploy, to: 'team_diagnostics#deploy'
    end
    resources :team_diagnostic_questions
  end
  resources :participants
end
