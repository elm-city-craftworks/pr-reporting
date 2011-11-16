require 'rubygems'
require 'gruff'

data = [0, 49, 69, 74, 91, 101, 110, 173, 186, 197, 221, 230, 242]

g = Gruff::Line.new(480)
g.title = "Paid Subscriptions" 

g.labels = (0...data.length).each_with_object({}) { |i,h| h[i] = i.to_s }
g.x_axis_label = "Week Number"

g.hide_legend = true
g.data("Subscribers", data)

g.write('subscribers_by_week.png') 
