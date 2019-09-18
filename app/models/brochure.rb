class Brochure < ApplicationRecord
  has_many :broshejointables
  has_many :sheets, through: :broshejointables

  def has_picture?
    !self.image.blank?
  end

  def has_content?
    !self.content.blank?
  end

  def brochures_in_order
  end

  def order_number(sheet)
    Broshejointable.where(:sheet_id=> sheet.id, :brochure => self.id).first.order_number
  end

end
