class Card < ApplicationRecord
  belongs_to :cribgame, optional: true
  belongs_to :cribplayer, optional: true
end
