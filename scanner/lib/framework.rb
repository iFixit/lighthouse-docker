require 'uri'

Page = Struct.new :name, :url

class Framework
  attr_reader :name

  def initialize(name, pages, hostname)
    @name = name
    @pages = pages
    @hostname = hostname
  end

  def pages
    @pages.map do |name, url|
      uri = URI.parse url
      uri.host = @hostname if @hostname
      Page.new name, uri
    end
  end
end
