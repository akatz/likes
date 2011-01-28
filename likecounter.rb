#!/usr/bin/ruby
require 'rubygems'
require 'open-uri'
require 'net/http'
require 'nokogiri'
require 'json'

class LikeFinder
  URLS = {
    :facebook => "http://graph.facebook.com/",
    :youtube  => "http://gdata.youtube.com/feeds/api/users/",
    :twitter  => "http://api.twitter.com/1/users/show.json?screen_name="
  }
  def initialize(company, services=["twitter","facebook","youtube"])
    @company = company
    @services = services.map {|x| x.to_sym}
  end

  def get_like_counts
    @services.map do |service|
      http = ::Net::HTTP.get(URI.parse("#{URLS[service.to_sym]}#{@company}"))
      if service == :youtube
        doc = ::Nokogiri::XML(http)
        val = doc.xpath('//yt:statistics').attr("viewCount").value
      else 
        if service == :facebook
          doc = ::JSON.parse(http)
          val = doc["likes"]
        else
          doc = ::JSON.parse(http)
          val = doc["followers_count"]
        end
      end
      [service, val]
    end
  end
end
if ARGV.size < 1
  puts "Usage:"
  puts "ruby likecounter.rb [company_name]"
else
  p = LikeFinder.new(ARGV[0])
  p.get_like_counts.each { |x| puts x.join " => "}
end


