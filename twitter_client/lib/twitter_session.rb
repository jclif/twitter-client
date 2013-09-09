require 'singleton'

class TwitterSession
  include Singleton

  CONSUMER_KEY = "ZeLDg28aQKJMcQ5iKnmRAQ"
  CONSUMER_SECRET = "GiLKq6Nb28IiD94IUpZH4WBKeUghn7HvflUM21uoM"

  CONSUMER = OAuth::Consumer.new(
    CONSUMER_KEY, CONSUMER_SECRET, :site => "https://twitter.com")

  def self.get(*args)
    self.instance.access_token.get(*args)
  end

  def self.post(*args)
    self.instance.access_token.get(*args)
  end

  def self.token
    p self.instance.access_token
  end

  attr_reader :access_token

  def initialize
    @access_token = read_or_request_access_token
  end

  protected
  def read_or_request_access_token
    request_token = CONSUMER.get_request_token
    authorize_url = request_token.authorize_url
    puts "Go to this URL: #{authorize_url}"

    Launchy.open(authorize_url)

    puts "Login, and type your verification code in"
    oauth_verifier = gets.chomp

    access_token = request_token.get_access_token(
      :oauth_verifier => oauth_verifier
    )
  end
end