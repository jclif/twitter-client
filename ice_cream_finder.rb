require 'addressable/uri'
require 'rest-client'
require 'nokogiri'
require 'socket'
require 'json'

class IceCreamFinder

  KEY = "AIzaSyBwlxzfPWyu8LR6A8afji653PTjZ3u304E"
  C_SECRET = "VNYxnDlTzF6ilXQfix4Iz_s6"

  attr_accessor :location, :icecreams

  def initialize
    self.location = current_location
    self.icecreams = find_ice_cream
  end

  def current_location
    ip = local_ip
    ip = "38.89.128.21" if ip == "10.1.21.252"
    location = { lat: 40.730804, lng: -73.9914 }

    current = Addressable::URI.new(
      scheme: "http",
      host: "api.hostip.info",
      path: "get_html.php",
      query_values: { ip: ip, position: true }
    ).to_s

    RestClient.get(current)

    # be fancy about finding location...later

    location
  end

  def find_ice_cream
    google_url = Addressable::URI.new(
        scheme: "https",
        host: "maps.googleapis.com",
        path: "maps/api/place/nearbysearch/json",
        query_values: {
          location: "#{self.location[:lat]},#{self.location[:lng]}",
          radius: 2000,
          sensor: false,
          types: "food",
          keyword: "icecream",
          key: KEY
        }
      ).to_s

    JSON.parse(RestClient.get(google_url))["results"].map do |result|
      result["geometry"]["location"]
    end
  end


  def local_ip
    origin = Socket.do_not_reverse_lookup
    Socket.do_not_reverse_lookup = true # turn off reverse DNS resolution temporarily
    UDPSocket.open do |s|
      s.connect '64.233.187.99', 1 #google
      s.addr.last
    end
  ensure
    Socket.do_not_reverse_lookup = origin
  end

end

if __FILE__ == $0
  i = IceCreamFinder.new
  p i.find_ice_cream
end
