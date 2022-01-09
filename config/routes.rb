# frozen_string_literal: true

Rails.application.routes.draw do
  resources :team_diagnostic_letters
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
        post :activate, to: 'participants#activate'
        post :resend_invitation, to: 'participants#resend_invitation'
      end
    end
    member do
      get 'wizard/:step', to: 'team_diagnostics#wizard', as: 'wizard'
      get 'export.:format', to: 'team_diagnostics#export', as: 'export'
      get 'report/:report_id', to: 'team_diagnostics#report', as: 'report'
      post :deploy, to: 'team_diagnostics#deploy'
      post :complete, to: 'team_diagnostics#complete'
      post :generate_report, to: 'team_diagnostics#generate_report'
      delete :cancel, to: 'team_diagnostics#cancel'
    end
    resources :team_diagnostic_questions
    resources :team_diagnostic_letters
  end
  resources :participants
  resources :diagnostic_surveys do
    collection do
      get :not_found, to: 'diagnostic_surveys#not_found'
    end
    member do
      post :complete, to: 'diagnostic_surveys#complete'
    end
  end
end
