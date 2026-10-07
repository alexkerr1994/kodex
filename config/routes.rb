Rails.application.routes.draw do
  # Local email inbox (development only) — see mail sent by the app.
  mount LetterOpenerWeb::Engine, at: "/letter_opener" if Rails.env.development?

  # Send Devise's generated account-edit page to our own Account settings tab.
  devise_scope :user do
    get "users/edit", to: redirect("/profile?tab=account")
  end
  devise_for :users

  resources :folders, only: %i[create update destroy]

  # Calendar
  get "calendar", to: "calendar#show", as: :calendar
  resources :events, only: %i[show new create edit update destroy]
  # Calendar management (distinct helpers so they don't clash with calendar_path).
  resources :calendars, only: %i[create update destroy show], as: :manage_calendars, path: "manage/calendars" do
    resources :shares, only: %i[create destroy], controller: "calendar_shares"
    resources :network_shares, only: %i[destroy], controller: "calendar_network_shares"
  end

  resource :profile, only: %i[show update destroy]
  patch  "/profile/account",  to: "profiles#update_account", as: :profile_account
  post   "/profile/referral", to: "profiles#refer",          as: :profile_referral

  # Managing your own tags (renaming/recolouring/deleting), distinct from the
  # per-note tagging under notes/:id/tags.
  resources :tags, only: %i[update destroy]

  # No new/edit: networks are created inline from the profile and have no
  # standalone form pages (bare `resources` would route to missing actions).
  resources :networks, only: %i[index show create update destroy] do
    resources :invitations, only: %i[create destroy], controller: "network_invitations"
    resources :memberships, only: %i[update destroy], controller: "network_memberships"
    delete "leave", to: "network_memberships#leave", as: :leave
  end
  # Invitee-facing accept/decline of one's own invitations.
  resources :invitations, only: [] do
    member do
      post :accept
      delete :decline
    end
  end

  # No new/edit: notes are created via a POST button and edited inline in the
  # detail pane (no standalone form pages).
  resources :notes, except: %i[new edit] do
    member do
      patch :toggle_task
      patch :restore
      delete :purge
      patch :move_tag
    end
    resource :archival, only: %i[create destroy], controller: "archivals"
    resources :shares, only: %i[create destroy], controller: "note_shares"
    resources :tags, only: %i[create destroy], controller: "note_tags"
    resources :shared_tags, only: %i[create destroy], controller: "note_shared_tags"
    resource :favorite, only: %i[create destroy], controller: "favorites"
    resources :network_shares, only: %i[destroy], controller: "note_network_shares"
    resource :filing, only: %i[update], controller: "note_filings"
  end

  root "notes#index"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"
end
