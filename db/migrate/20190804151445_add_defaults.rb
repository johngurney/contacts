class AddDefaults < ActiveRecord::Migration[5.2]
  def change

    change_column_default :contacts, :first_name, ""
    change_column_default :contacts, :last_name, ""
    change_column_default :contacts, :position, ""
    change_column_default :contacts, :tel_number, ""
    change_column_default :contacts, :mobile_number, ""
    change_column_default :contacts, :url, ""
    change_column_default :contacts, :description, ""
    change_column_default :contacts, :email_address, ""

    change_column_default :sheets, :client_name, ""
    change_column_default :sheets, :number, "000000"

    change_column_default :contact_sheets, :sheet_id, 0
    change_column_default :contact_sheets, :contact_id, 0
    change_column_default :contact_sheets, :order, 0

  end
end
