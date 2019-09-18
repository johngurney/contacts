class Sheet < ApplicationRecord
  has_many :contact_sheets
  has_many :conshejointables
  has_many :contacts, through: :conshejointables

  has_many :broshejointables
  has_many :brochures, through: :broshejointables

  def contacts_emails
    email_address = ""
    self.contacts.each do |contact|
      email_address += ";" if email_address != ""
      email_address += contact.email_address
    end
    email_address
  end

  def check_orders_number_are_null
    Conshejointable.where(:sheet_id => self.id, :order_number => nil ).order(:contact_id).each do |contact_sheet|
      contact_sheet.order_number = self.max_order
      contact_sheet.save
    end

  end

  def check_brochure_orders_number_are_null
    Broshejointable.where(:sheet_id => self.id, :order_number => nil ).order(:brochure_id).each do |brochure_sheet|
      brochure_sheet.order_number = self.max_order
      brochure_sheet.save
    end

  end


  def contacts_in_order
    self.check_orders_number_are_null
    self.contacts.all.sort{|contact1, contact2|  find_order(contact1.id, self.id) <=> find_order(contact2.id, self.id) }
  end

  def brochures_in_order
    self.check_brochure_orders_number_are_null
    self.brochures.all.sort{|brochure1, brochure2|  find_order(brochure1.id, self.id) <=> find_order(brochure2.id, self.id) }
  end


  def find_order(contact_id, sheet_id)
    Conshejointable.where(:contact_id => contact_id, :sheet_id => sheet_id).first.order_number
  end

  def max_order
    Conshejointable.where(:sheet_id => self.id).where.not(:order_number => nil).count == 0 ? 0 : (Conshejointable.where(:sheet_id => self.id).maximum(:order_number) + 1)
  end

  def max_brochure_order
    Broshejointable.where(:sheet_id => self.id).where.not(:order_number => nil).count == 0 ? 0 : (Broshejointable.where(:sheet_id => self.id).maximum(:order_number) + 1)
  end
end
