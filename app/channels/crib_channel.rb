class CribChannel < ApplicationCable::Channel
  def subscribed
    stream_from 'room_channel' + uuid

    # stream_from "some_channel"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
