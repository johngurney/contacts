Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root 'homepage#homepage'
  post 'add_contact' => 'homepage#add_contact', as: :add_contact
end
