Rails.application.routes.draw do
  get 'contact_sheet/:id' , to: 'sheets#sheet', as: :contact_sheet
  resources :sheets
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root 'homepage#homepage'
  post 'add_contact' => 'homepage#add_contact', as: :add_contact

  resources :contacts

  post 'sheet/addcontact/.:id' , to: 'sheets#add_contact', as: :add_contact_to_sheet
  post 'sheet/removecontact/.:id' , to: 'sheets#remove_contact', as: :remove_contact_from_sheet

end
