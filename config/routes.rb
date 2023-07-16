Rails.application.routes.draw do
  root 'people#index'

  resources :people, only: %i[index]

  get 'cards/download'
  resources :cards, only: %i[show create]
end
