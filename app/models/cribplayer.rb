class Cribplayer < ApplicationRecord
  belongs_to :cribgame, optional: true
  has_many :cards

end
