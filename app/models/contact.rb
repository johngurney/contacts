class Contact < ApplicationRecord
  has_many :conshejointables
  has_many :sheets, through: :conshejointables

  has_many :descriptions


  def name
    self.first_name + " " + self.last_name
  end

  def order_number(sheet)
    Conshejointable.where(:sheet_id=> sheet.id, :contact_id => self.id).first.order_number
  end

  def descs_in_order
    self.descriptions.order(:name)
  end

  def has_picture?
    # filename = Rails.root.join("public", self.picture_filename).to_s
    # File.exist?(filename)

    !self.image.blank?

  end

  def picture_filename
    "pictures/picture"  + self.id.to_s + ".jpg"
  end

  def get_description(sheet)
    if self.descriptions.count > 0
      description_lookups = Conshejointable.where(:contact_id => self.id, :sheet_id => sheet.id)
      if description_lookups.count != 0
        description_id = description_lookups.first.description_id
        return Description.find(description_id).text if !description_id.blank?
      end
      self.descriptions.first.text
    end
  end

  def set_selector(description_id)
    descs_in_order = self.descs_in_order
    if !descs_in_order.blank?
      descs_in_order.first.id if description_id == 0
      ApplicationController.helpers.select_tag :select, ApplicationController.helpers.options_for_select(descs_in_order.map{ |description| [description.name, description.id]}, description_id).html_safe,  {:class => "standard", :onchange => "document.getElementById(\'select_button\').click();".html_safe }
    end
  end

  def test
    "hello" if true
    "goodbye"
  end


end


# <%= form_tag contact_desc_path(@contact), remote: true,  :id => 'desc_form' do %>
#
#     <%= select_tag :select, options_for_select( @contact.descriptions.order(:name).all.map{|description| [description.name, description.id]}, "") , {:onchange => 'desc_form.submit()'} %>
#
#   <%= text_area_tag :desc, "", {class: "standard", style: "width:97%; height: 200px"} %>
#   <%= submit_tag "Update" %>
# <% end %>

#ActionController::InvalidAuthenticityToken (ActionController::InvalidAuthenticityToken):

#<%= select_tag :select, options_for_select( @contact.descriptions.order(:name).all.map{|description| [description.name, description.id]}, @contact.descriptions.order(:name).first.id) , {:class => "standard", :style => "width:80%;", :onchange => '("select_button").click();'.html_safe } %>



# <%= form_tag contact_desc_path(@contact), remote: true,  :id => 'desc_form' do %>
#
#     <%= select_tag :select, options_for_select( @contact.descriptions.order(:name).all.map{|description| [description.name, description.id]}, "") , {:onchange => '("select_button").click();'.html_safe } %>
#
#     <div style="display: none">
#         <%= submit_tag "Select", :id => "select_button", :style =>"width: 120px" %>
#     </div>
#
#   <%= text_area_tag :desc, "", {class: "standard", style: "width:97%; height: 200px"} %>
#   <%= submit_tag "Update" %>
# <% end %>
