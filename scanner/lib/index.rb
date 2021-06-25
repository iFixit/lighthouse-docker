class Index
   def initialize
      @urlmap = {}
   end

   def add framework, page
      @urlmap[framework] ||= []
      @urlmap[framework].push page
   end

   def generate_index scan_dir
      log :info, "Generating index file"
      File.write(scan_dir/"index.json", JSON.dump(@urlmap))
      File.write scan_dir/"index.html", generate_html_map
   end

   def generate_html_map
      return <<~MAPHTML
      <html><body>
      <h1>LightHouse Scan Results</h1>
      #{generate_frameworks_list}
      </body></html>
      MAPHTML
   end

   def generate_frameworks_list
      @urlmap.map do |framework, pages|
         <<~UL
         <h3>#{framework}</h3>
         <ul>
         #{get_page_links framework, pages}
         </ul>
         UL
      end.join("\n")
   end

   def get_page_links framework, pages
      pages.map do |name|
         html_url = "#{framework}/#{name}.report.html"
         json_url = "#{framework}/#{name}.report.json"
         <<~LI
         <li>
         <a href="#{html_url}">#{name}</a> <a href="#{json_url}">(#{name}.json)</a>
         </li>
         LI
      end.join("\n")
   end
end
