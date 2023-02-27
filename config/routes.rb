Rails.application.routes.draw do
  resources :reports
  resources :accounts

  resources :teams
  resources :feedbacks, except: [:get, :post]
  get 'teams/:team_id/feedbacks', to: 'feedbacks#new'
  post 'teams/:team_id/feedbacks', to: 'feedbacks#create', as: 'team_feedbacks'
  root 'static_pages#home'
  get '/help', to: 'static_pages#help'
  get 'team_view/help', to: 'teams#help'
  get 'regenerate_admin_code', to: 'options#regenerate_admin_code'
  get 'reset_password', to: 'static_pages#show_reset_password'
  post 'reset_password', to: 'static_pages#reset_password'

  get 'teams/:id/confirm_delete_user_from_team', to: 'teams#confirm_delete_user_from_team', as: 'team_confirm_delete_delete_user_from_team'
  get 'teams/:id/confirm_delete', to: 'teams#confirm_delete', as: 'team_confirm_delete'
  resources :teams

  get 'users/:id/confirm_delete', to: 'users#confirm_delete', as: 'user_confirm_delete'
  get 'users/:id/regenerate_password', to: 'users#regenerate_password', as: 'user_regenerate_password'

  get    '/login',  to: 'sessions#new'
  post   '/login',  to: 'sessions#create'
  get    '/logout', to: 'sessions#destroy'
  get '/signup', to: 'users#new'
  resources :users, except: [:new]
  resources :options do
    post :toggle_reports
  end
  resources :teams do
    post :remove_user_from_team
  end

  resources :courses
  post '/teams/:id/users', to: 'teams#add_members', as: 'team_add_members'
  post '/users/:user_id/teams/:team_id', to: 'users#accept_team_invite', as: 'user_accept_team_invite'
  # get 'courses/:course_id', to: 'courses#show'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end


