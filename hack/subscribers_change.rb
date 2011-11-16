require 'rubygems'
require 'gruff'

data = [49, 69, 74, 91, 101, 110, 173, 186, 197, 221, 230, 242]
data = data.each_cons(2).map { |a,b| b - a }

g = Gruff::Line.new(480)
g.title = "Change in subscriber count by week" 

g.labels = (0...data.length).each_with_object({}) { |i,h| h[i] = "#{i + 2}" }
g.x_axis_label = "Week Number"

g.hide_legend = true
g.data("Subscribers", data)

g.write('subscribers.png') 
