Rails.application.routes.draw do

  resources :sheets
  resources :contacts
  resources :brochures


  get 'contact_sheet/:id' , to: 'sheets#contact_sheet', as: :contact_sheet
  get 'contact_sheet_internal/:id' , to: 'sheets#contact_sheet_no_log', as: :contact_sheet_no_log


  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root 'homepage#homepage'
  post 'add_contact' => 'homepage#add_contact', as: :add_contact


  post 'sheet/addcontact/.:id' , to: 'sheets#add_contact', as: :add_contact_to_sheet
  post 'sheet/update_contact/.:id' , to: 'sheets#update_contact', as: :update_contact_for_sheet
  post 'sheet/addbrochure/.:id' , to: 'sheets#add_brochure', as: :add_brochure_to_sheet
  post 'sheet/brochure_contact/.:id' , to: 'sheets#update_brochure', as: :update_brochure_for_sheet

  get 'sheet/order_up/:sheet_id/:contact_id' , to: 'sheets#order_up', as: :sheet_order_up
  get 'sheet/order_down/:sheet_id/:contact_id' , to: 'sheets#order_down', as: :sheet_order_down
  get 'sheet/to_top/:sheet_id/:contact_id' , to: 'sheets#to_top', as: :to_top
  get 'sheet/to_bottom/:sheet_id/:contact_id' , to: 'sheets#to_bottom', as: :to_bottom

  post 'upload_contacts_file', to:  "contacts#upload_contacts_file" , as:  :upload_contacts_file
  post 'delete_all_contacts', to:  "contacts#delete_all_contacts" , as:  :delete_all_contacts

  post 'cookie_consent'=> 'homepage#cookie_consent', as: :cookie_consent
  post 'log_in'=> 'homepage#log_in', as: :log_in
  get 'reset_cookie_consent' , to: 'homepage#reset_cookie_consent', as: :reset_cookie_consent
  get 'log_out' , to: 'homepage#log_out', as: :log_out

  post 'upload_picture/.:id' , to: 'contacts#upload_picture', as: :cont_upload_picture
  get 'get_picture/.:id', to: 'contacts#get_picture', as: :get_cont_picture

  get 'get_qr_code/.:id', to: 'sheets#get_qr_code', as: :get_qr_code

  post 'contact_desc/.:id'=> 'contacts#desc', as: :contact_desc

  post 'upload_broch_image/.:id' , to: 'brochures#upload_picture', as: :broch_upload_picture
  post 'upload_broch_pdf/.:id' , to: 'brochures#upload_pdf', as: :broch_upload_pdf

  get 'get_broch_picture/.:id', to: 'brochures#get_picture', as: :get_broch_picture
  get 'download_content/.:id' , to: 'brochures#download_content', as: :download_content
  get 'usage/.:id' , to: 'sheets#usage', as: :usage
  get 'usage_image/.:id' , to: 'sheets#usage_image', as: :usage_image

  get 'test' , to: 'homepage#test', as: :test

  mount_griddler
  #https://github.com/thoughtbot/griddler


  post 'position', to:  "homepage#position"
  get "location", to:  "homepage#location", as: :location
  get "location_log", to:  "homepage#location_log", as: :location_log
  post "location_controls", to:  "homepage#location_controls", as: :location_controls
  post "clear_all_location_logs", to:  "homepage#clear_all_location_logs", as: :clear_all_location_logs
  post "download_location_logs", to:  "homepage#download_location_logs", as: :download_location_logs

  get "stick_man", to:  "homepage#stick_man"

end
