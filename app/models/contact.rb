class Contact < ApplicationRecord
  has_and_belongs_to_many :sheets

  def name
    self.first_name + " " + self.last_name
  end
end
