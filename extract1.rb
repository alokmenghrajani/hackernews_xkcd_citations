#!/usr/bin/env ruby
require 'json'
require 'htmlentities'

# Calculate top 10 most cited XKCD comics and print output to stdout

# Load xkcd.jsonl
imgs = {}
File.foreach("xkcd.jsonl") do |line|
  data = JSON.parse(line)
  imgs[data["img"]] = data["id"]
end

stats = {}
# Load raw.jsonl
File.foreach("raw.jsonl") do |line|
  data = JSON.parse(line)
  text = HTMLEntities.new.decode(data["text"])
  h = {}

  # Grab xkcd.com/<id>, www.xkcd.com/<id>
  # and m.xkcd.com/<id>.
  m = text.scan(/(?:www\.|m\.)?xkcd\.com\/([0-9]+)/i).flatten
  m.each do |id|
    id = id.to_i
    h[id]=true
  end

  # Grab various forms of "xkcd #1234"
  m = text.scan(/xkcd [^a-z0-9]*([0-9]+)/i).flatten
  m.each do |id|
    id = id.to_i
    h[id]=true
  end

  # Grab imgs.xkcd.com/<img> and convert to comic id
  m = text.scan(/(imgs\.xkcd\.com\/.*?(?:png|gif|jpg))/i).flatten
  m.each{|img|
    i = "https://" + img
    if imgs[i] then
      h[imgs[i]] = true
    else
      #puts "unknown: " + i
    end
  }

  # Add the data from h to stats
  h.each do |key, value|
    if !stats[key] then
      stats[key] = 0
    end
    stats[key] += 1
  end
end

# Sort and emit top 10
puts stats.sort_by {|_key, value| value}.last(10).reverse().to_h
