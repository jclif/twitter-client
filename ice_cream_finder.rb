require 'addressable/uri'
require 'rest-client'
require 'nokogiri'
require 'socket'
require 'json'
# require 'debugger'; debugger

class IceCreamFinder

  KEY = "AIzaSyBwlxzfPWyu8LR6A8afji653PTjZ3u304E"
  C_SECRET = "VNYxnDlTzF6ilXQfix4Iz_s6"

  def self.display_route(dir)
    puts dir[:name]
    puts "#{dir[:distance]} meters"

    dir[:steps].each do |step|
      step_txt = Nokogiri::HTML(step["html_instructions"]).text
      puts step_txt.gsub("Destination", "\nDestination")
    end
  end

  attr_accessor :location, :ice_creams

  def initialize
    @location = current_location
    @ice_creams = find_ice_cream
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
          location: "#{location[:lat]},#{location[:lng]}",
          radius: 2000,
          sensor: false,
          types: "food",
          keyword: "icecream",
          key: KEY
        }
      ).to_s

    JSON.parse(RestClient.get(google_url))["results"].map do |result|
      result["geometry"]["location"].merge({"name" => result["name"]})
    end
  end

  def closest_ice_cream
    ice_creams_dir = ice_creams.map do |ice_cream|
      begin
        directions_url = Addressable::URI.new(
          scheme: "https",
          host: "maps.googleapis.com",
          path: "maps/api/directions/json",
          query_values: {
            origin: "#{location[:lat]},#{self.location[:lng]}",
            destination: "#{ice_cream["lat"]},#{ice_cream["lng"]}",
            sensor: false,
            mode: "walking"
          }
        ).to_s

        result = {}

        dir = JSON.parse(RestClient.get(directions_url))

        result[:distance] = dir["routes"][0]["legs"][0]["duration"]["value"]
        result[:steps] = dir["routes"][0]["legs"][0]["steps"]
        result[:name] = ice_cream["name"]
      rescue
        status = get_status(dir)
        if status == "OVER_QUERY_LIMIT"
          sleep 2
          retry
        end
      end
        result
      end

    ice_creams_dir.sort { |x, y| x[:distance] <=> y[:distance] }.first
  end


  def get_status(hash)
    hash["status"]
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
  # p i.closest_ice_cream
  IceCreamFinder.display_route(i.closest_ice_cream)
end
