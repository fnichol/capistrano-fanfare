require 'net/https'
require 'multi_json'

module Capistrano
  module Fanfare
    module Campfire
      class Room
        # Public: Error class raised when a room ID cannot be found with a
        # given name.
        class NotFound < RuntimeError ; end

        # Public: Error class raised when an HTTP error has occured.
        class ConnectionError < RuntimeError ; end

        # Public: Returns the String account name.
        attr_reader :account

        # Public: Returns the String room name.
        attr_reader :room

        # Public: Returns the API token String for a user.
        attr_reader :ssl

        # Public: Initializes a Room from a Hash of configuration options.
        #
        # options - A Hash of options to set up the Room (default: {}):
        #           :account  - The String account/subdomain name.
        #           :room     - The String room name, not the room ID.
        #           :token    - The API token String for a user.
        #           :ssl      - A truthy object which is true when SSL is
        #                       required (default: true).
        def initialize(options = {})
          options = { :ssl => true }.merge(options)

          [:account, :room, :token, :ssl].each do |option|
            instance_variable_set "@#{option}", options[option]
          end
        end

        # Public: Returns the Integer room ID of the Campfire room.
        #
        # Returns the Integer room ID.
        # Raises NotFound if a room cannot be found for the given name.
        # Raises ConnectionError if an HTTP error occurs.
        def room_id
          @room_id ||= fetch_room_id
        end

        # Public: Posts a message into the campfire room.
        #
        # msg - A String message.
        #
        # Returns true if message is delivered.
        # Raises ConnectionError if an HTTP error occurs.
        def speak(msg)
          send_message(msg)
        end

        # Public: Plays a sound into the campfire room.
        #
        # sound - A String representing the sound.
        #
        # Returns true if message is delivered.
        # Raises ConnectionError if an HTTP error occurs.
        def play(msg)
          send_message(msg, 'SoundMessage')
        end

        private

        # Internal: Array of errors that will be wrapped when using Net::HTTP.
        HTTP_ERRORS = [Timeout::Error, Errno::EINVAL, Errno::ECONNRESET,
          EOFError, Net::HTTPBadResponse, Net::HTTPHeaderSyntaxError,
          Net::ProtocolError, SocketError, OpenSSL::SSL::SSLError,
          Errno::ECONNREFUSED]

        # Internal: Returns the API token String for a user.
        attr_reader :token

        # Internal: Returns the campfire hostname with subdomain.
        def host
          "#{account}.campfirenow.com"
        end

        # Internal: Returns the Integer HTTP port number to connect with.
        def port
          ssl ? 443 : 80
        end

        # Internal: Returns the Integer number of the room.
        #
        # Returns the Integer room number.
        # Raises NotFound if a room cannot be found for the given name.
        # Raises ConnectionError if an HTTP error occurs.
        def fetch_room_id
          connect do |http|
            response = http.request(http_request(:get, "/rooms.json"))

            case response
            when Net::HTTPOK
              find_room_in_json(MultiJson.decode(response.body))
            else
              raise ConnectionError
            end
          end
        end

        # Internal: Posts a message to the campfire room.
        #
        # msg   - The String message to send.
        # type  - The String type of campfire message (default: TextMessage).
        #
        # Returns true if message is delivered.
        # Raises ConnectionError if an HTTP error occurs.
        def send_message(msg, type = 'TextMessage')
          connect do |http|
            request = http_request(:post, "/room/#{room_id}/speak.json")
            request.body = MultiJson.encode(
              { :message => { :body => msg, :type => type } })
            response = http.request(request)

            case response
            when Net::HTTPCreated
              true
            else
              raise ConnectionError,
                "Error sending message '#{msg}' (#{response.class})"
            end
          end
        end

        # Internal: Parses through the rooms JSON response and returns the
        # Integer room ID.
        #
        # json  - the rooms Hash of JSON data.
        #
        # Returns the Integer room number.
        # Raises NotFound if a room cannot be found for the given name.
        def find_room_in_json(json)
          room_hash = json["rooms"].find { |r| r["name"] == room }

          if room_hash
            room_hash["id"]
          else
            raise NotFound, "Room name '#{room}' could not be found."
          end
        end

        # Internal: Creates a Net::HTTP connection and yields to a block with
        # the connection.
        #
        # Yields the Net::HTTP connection.
        #
        # Returns the return value (if any) of the block.
        # Raises ConnectionError if any common HTTP errors are raised.
        def connect
          http = Net::HTTP.new(host, port)
          http.use_ssl = ssl

          begin
            yield http
          rescue *HTTP_ERRORS => exception
            raise ConnectionError, "#{exception.class.name}: #{exception.message}"
          end
        end

        # Internal: Returns a Net::HTTPRequest object initialized with
        # authentication and content headers set.
        #
        # verb  - A Symbol representing an HTTP verb.
        # path  - The String path of the request.
        #
        # Examples
        #
        #   http_request(:get, "/rooms.json")
        #   http_request(:post, "/room/1/speak.json")
        #
        # Returns a Net::HTTPRequest object.
        def http_request(verb, path)
          klass = klass = Net::HTTP.const_get(verb.to_s.capitalize)
          request = klass.new(path)
          request.basic_auth(token, "X")
          request["Content-Type"] = "application/json"
          request
        end
      end
    end
  end
end
