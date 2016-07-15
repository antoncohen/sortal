Rails.application.routes.draw do
  match '/auth/:provider/callback', to: 'sessions#create', via: [:get, :post]
  match '/logout', to: 'sessions#destroy', as: 'logout', via: [:delete]
  get '/login', to: redirect('/', status: 307)

  post 'submit/jira'

  root 'home#index'

  get ':section/:topic', to: 'topics#display', constraints: {
    section: /[a-z0-9-]+/, topic: /[a-z0-9-]+/
  }

  #get '/:section', to: redirect('/', status: 307)

  root 'home#index'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
