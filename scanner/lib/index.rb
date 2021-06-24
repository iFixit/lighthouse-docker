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
   end
end
