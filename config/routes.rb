Rails.application.routes.draw do
  post 'submit/jira'

  root 'home#index'

  get ':section/:topic', to: 'topics#display', constraints: {
    section: /[a-z0-9-]+/, topic: /[a-z0-9-]+/
  }

  #get '/:section', to: redirect('/', status: 307)
  #get 'home/index'



  #resources :topics

  root 'home#index'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
