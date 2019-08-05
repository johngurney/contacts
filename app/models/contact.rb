class Contact < ApplicationRecord
  has_many :contact_sheets
  has_many :sheets, through: :contact_sheets

  def name
    self.first_name + " " + self.last_name
  end

  def order_number(sheet)
    ContactSheet.where(:sheet_id=> sheet.id, :contact_id => self.id).first.order_number
  end
end
