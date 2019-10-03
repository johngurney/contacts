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

  def qr_code
    #https://github.com/whomwah/rqrcode

    require 'rqrcode'

    qrcode = RQRCode::QRCode.new(Rails.application.routes.url_helpers.contact_sheet_url(:id => self.number))

    # NOTE: showing with default options specified explicitly
    # svg = qrcode.as_svg(
    #   offset: 0,
    #   color: '000',
    #   shape_rendering: 'crispEdges',
    #   module_size: 6,
    #   standalone: true
    # ).html_safe
    #
    png = qrcode.as_png(
      bit_depth: 1,
      border_modules: 4,
      color_mode: ChunkyPNG::COLOR_GRAYSCALE,
      color: 'black',
      file: nil,
      fill: 'white',
      module_px_size: 6,
      resize_exactly_to: false,
      resize_gte_to: false,
      size: 120
    )

    png

  end

  def usage_months
    number_of_months = 0..11
    stg = ""
    number_of_months.to_a.reverse.each do |month_offset|
      stg += ", " if stg != ""
      stg += "\"" + month_offset.months.ago.strftime("%b %y") + "\""
    end
    stg
  end

  def usage_values
    number_of_months = 0..11
    stg = ""
    number_of_months.to_a.reverse.each do |month_offset|
      stg += ", " if stg != ""
      m = month_offset.months.ago
      stg += Log.where(:sheet_id => self.id).where("created_at >= ? and created_at <= ?", m.beginning_of_month, m.end_of_month).count.to_s
    end
    stg
  end

  def max_value
    number_of_months = 0..11
    v = 1
    number_of_months.to_a.reverse.each do |month_offset|
      m = month_offset.months.ago
      n =  Log.where(:sheet_id => self.id).where("created_at >= ? and created_at <= ?", m.beginning_of_month, m.end_of_month).count
      v = n if n > v
      puts "******" + n.to_s + " " + v.to_s
    end
    v.to_s
  end

end
