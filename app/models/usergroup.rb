class Usergroup < ApplicationRecord
  has_and_belongs_to_many :users do
    def << user
      super user if !self.include? user
    end
  end
end
