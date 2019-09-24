Rails.application.routes.draw do
  devise_for :users
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  root to: 'users#profile'
  resources :users
  post 'apply_leave', to: 'users#apply_leave'
  post 'find_leaves_record', to: 'users#find_leaves_record'
  post 'cancel_leaves', to: 'users#cancel_leaves'
  post 'edit_leaves', to: 'users#edit_leaves'
  post 'final_action', to: 'users#final_action'
end
