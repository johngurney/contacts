class Sheet < ApplicationRecord
  has_many :contact_sheets
  has_many :contacts, through: :contact_sheets

  def contacts_emails
    email_address = ""
    self.contacts.each do |contact|
      email_address += ";" if email_address != ""
      email_address += contact.email_address
    end
    email_address
  end

  def check_orders_number_are_null
    ContactSheet.where(:sheet_id => self.id, :order_number => nil ).order(:contact_id).each do |contact_sheet|
      contact_sheet.order_number = self.max_order
      contact_sheet.save
    end

  end

  def contacts_in_order
    self.check_orders_number_are_null
    self.contacts.all.sort{|contact1, contact2|  find_order(contact1.id, self.id) <=> find_order(contact2.id, self.id) }
  end

  def find_order(contact_id, sheet_id)
    ContactSheet.where(:contact_id => contact_id, :sheet_id => sheet_id).first.order_number
  end

  def max_order
    ContactSheet.where(:sheet_id => self.id).where.not(:order_number => nil).count == 0 ? 0 : (ContactSheet.where(:sheet_id => self.id).maximum(:order_number) + 1)

  end

end
