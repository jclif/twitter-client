require 'addressable/uri'
require 'rest-client'
require 'nokogiri'
require 'socket'

class IceCreamFinder

  KEY = "AIzaSyBwlxzfPWyu8LR6A8afji653PTjZ3u304E"
  C_SECRET = "VNYxnDlTzF6ilXQfix4Iz_s6"

  # Find current location with hostip
  def current_location
    ip = local_ip
    ip = "38.89.128.21" if ip == "10.1.21.252"

    current = Addressable::URI.new(
      scheme: "http",
      host: "api.hostip.info",
      path: "get_html.php",
      query_values: { ip: ip, position: true }
    ).to_s

    RestClient.get(current)
  end

  # Use places api to find ice cream places

  # parse googles response

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
  puts i.current_location
end
