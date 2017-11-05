# frozen_string_literal: true

require "rack"
require "litecable"
require "lite_cable/server"

# Sample chat application
module Chat
  class Connection < LiteCable::Connection::Base # :nodoc:
    identified_by :user, :sid

    def connect
      @user = cookies["user"]
      @sid = request.params["sid"]
    end
  end

  class Channel < LiteCable::Channel::Base # :nodoc:
    identifier :chat

    def subscribed
      reject unless chat_id
      stream_from "chat_#{chat_id}"
    end

    def speak(data)
      LiteCable.broadcast "chat_#{chat_id}", text: data["message"]
    end

    def reject
      log(:debug) { "Rejected!" }
      super
    end

    private

    def chat_id
      params["id"]
    end
  end
end

app = Rack::Builder.new
app.map "/cable" do
  use(LiteCable::Server::Middleware, connection_class: Chat::Connection)
  run(proc { |_| [200, { "Content-Type" => "text/plain" }, ["OK"]] })
end

run app
