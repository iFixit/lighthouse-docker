require 'uri'

Page = Struct.new :name, :url

class Framework
  attr_reader :name
  attr_accessor :pages

  def initialize(name, pages, hostname)
    @name = name
    @pages = unpack_pages pages, hostname
  end

  def unpack_pages(pages, hostname)
    pages.map do |name, url|
      uri = URI.parse url
      uri.host = hostname if hostname
      Page.new name, uri
    end
  end
end
