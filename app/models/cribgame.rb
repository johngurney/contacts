class Cribgame < ApplicationRecord
  has_many :cribplayers
  has_many :cards


end
