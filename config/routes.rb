Rails.application.routes.draw do

  get 'contact_sheet/:id' , to: 'sheets#sheet', as: :contact_sheet
  resources :sheets
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root 'homepage#homepage'
  post 'add_contact' => 'homepage#add_contact', as: :add_contact

  resources :contacts

  post 'sheet/addcontact/.:id' , to: 'sheets#add_contact', as: :add_contact_to_sheet
  post 'sheet/removecontact/.:id' , to: 'sheets#remove_contact', as: :remove_contact_from_sheet

  get 'sheet/order_up/:sheet_id/:contact_id' , to: 'sheets#order_up', as: :sheet_order_up
  get 'sheet/order_down/:sheet_id/:contact_id' , to: 'sheets#order_down', as: :sheet_order_down
  get 'sheet/to_top/:sheet_id/:contact_id' , to: 'sheets#to_top', as: :to_top
  get 'sheet/to_bottom/:sheet_id/:contact_id' , to: 'sheets#to_bottom', as: :to_bottom

  post 'upload_contacts_file', to:  "contacts#upload_contacts_file" , as:  :upload_contacts_file
  post 'delete_all_contacts', to:  "contacts#delete_all_contacts" , as:  :delete_all_contacts

  post 'cookie_consent'=> 'homepage#cookie_consent', as: :cookie_consent
  get 'reset_cookie_consent' , to: 'homepage#reset_cookie_consent', as: :reset_cookie_consent


  mount_griddler
  #https://github.com/thoughtbot/griddler
end
