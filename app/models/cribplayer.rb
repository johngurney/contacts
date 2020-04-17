class Cribplayer < ApplicationRecord
  def other_player
    if self.number == 1
      Cribplayer.where(:number => 2).first
    else
      Cribplayer.where(:number => 1).first
    end
  end
end
