#!/usr/bin/env ruby
require 'json'
require 'htmlentities'

STDIN.each_line do |line|
  data = JSON.parse(line)
  data["text"] = HTMLEntities.new.decode(data["text"])
  puts data.to_json
end
