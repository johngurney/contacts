class Sheet < ApplicationRecord
  has_and_belongs_to_many :contacts

  def contacts_emails
    email_address = ""
    self.contacts.each do |contact|
      email_address += ";" if email_address != ""
      email_address += contact.email_address
    end
    email_address
  end
end
