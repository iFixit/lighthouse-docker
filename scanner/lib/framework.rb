require 'uri'

Page = Struct.new :name, :url

class Framework
   attr_reader :name
   attr_accessor :pages

   def initialize name, pages, hostname
      @name = name
      @pages = unpack_pages pages, hostname
   end

   def unpack_pages pages, hostname
      return pages.map do |name, url|
         uri = URI.parse url
         if hostname
            uri.host = hostname
         end
         Page.new name, uri
      end
   end
end
