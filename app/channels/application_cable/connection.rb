module ApplicationCable
  class Connection < ActionCable::Connection::Base

    identified_by :uuid
    def connect
        self.uuid = cookies[:crib_id]
    end
  end
end
