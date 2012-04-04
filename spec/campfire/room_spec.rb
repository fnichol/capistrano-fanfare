require 'minitest/autorun'
require 'webmock/minitest'
require 'capistrano/fanfare/campfire/room'

describe Capistrano::Fanfare::Campfire::Room do
  let(:opts) do
    { :account => 'zubzub', :token => 'yepyep',
      :room => 'myroom', :ssl => true }
  end

  let(:stub_rooms!) do
    stub_request(:get, "https://yepyep:X@zubzub.campfirenow.com/rooms.json").
      with(:headers => {'Accept'=>'*/*', 'Content-Type'=>'application/json',
           'User-Agent'=>'Ruby'}).
      to_return(:status => 200, :body => fixture("rooms"), :headers => {})
  end

  let(:stub_rooms_no_room!) do
    stub_request(:get, "https://yepyep:X@zubzub.campfirenow.com/rooms.json").
      with(:headers => {'Accept'=>'*/*', 'Content-Type'=>'application/json',
           'User-Agent'=>'Ruby'}).
      to_return(:status => 200, :body => fixture("no_rooms"), :headers => {})
  end

  let(:stub_rooms_invalid_token!) do
    stub_request(:get, "https://yepyep:X@zubzub.campfirenow.com/rooms.json").
      with(:headers => {'Accept'=>'*/*', 'Content-Type'=>'application/json',
           'User-Agent'=>'Ruby'}).
      to_return(:status => 401, :body => "HTTP Basic: Access denied.\n",
                :headers => {})
  end

  def stub_rooms_error!(error)
    stub_request(:get, "https://yepyep:X@zubzub.campfirenow.com/rooms.json").
      with(:headers => {'Accept'=>'*/*', 'Content-Type'=>'application/json',
           'User-Agent'=>'Ruby'}).
      to_raise(error)
  end

  def fixture(name)
    File.read(File.dirname(__FILE__) + "/../fixtures/campfire/webmock_#{name}.txt")
  end

  describe "#initialize" do
    it "takes a hash of campfire configuration" do
      room = Capistrano::Fanfare::Campfire::Room.new(opts)
      room.account.must_equal 'zubzub'
      room.room.must_equal    'myroom'
    end
  end

  describe "#room_id" do
    let(:subject) { Capistrano::Fanfare::Campfire::Room.new(opts) }

    it "fetches the room id from the API" do
      stub_rooms!
      subject.room_id.must_equal 666666
    end

    it "raises NotFound if no room is found" do
      stub_rooms_no_room!

      proc { subject.room_id }.must_raise(
        Capistrano::Fanfare::Campfire::Room::NotFound)
    end

    it "raises ConnectionError if the token is invalid" do
      stub_rooms_invalid_token!

      proc { subject.room_id }.must_raise(
        Capistrano::Fanfare::Campfire::Room::ConnectionError)
    end

    [Timeout::Error, Errno::EINVAL, Errno::ECONNRESET, EOFError,
      Net::HTTPBadResponse, Net::HTTPHeaderSyntaxError, Net::ProtocolError,
      SocketError, OpenSSL::SSL::SSLError, Errno::ECONNREFUSED
    ].each do |error|
      it "wraps #{error} and raises a ConnectionError" do
        stub_rooms_error!(error)

        proc { subject.room_id }.must_raise(
          Capistrano::Fanfare::Campfire::Room::ConnectionError)
      end
    end
  end
end
