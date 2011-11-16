require 'rubygems'
require 'gruff'


module Statistics
  def sum
    return reduce(:+)
  end
 
  def mean
    return sum / self.length.to_f
  end
 
  def sample_variance
    avg = mean
    sum = inject(0){|acc,i|acc +(i-avg)**2}
    return(1/length.to_f*sum)
  end
 
  def standard_deviation
    return Math.sqrt(sample_variance)
  end
end
  
data = [0, 0, 49, 69, 74, 91, 101, 110, 173, 186, 197, 221, 230, 242]

data    = data.each_cons(2).map { |a,b| b - a }


stats = data[1..-1]
stats.extend(Statistics)

p stats.mean


p stats.standard_deviation

without_outliers = stats.select { |e| 
  ((stats.mean - stats.standard_deviation)..(stats.mean + stats.standard_deviation)).include?(e)
}

without_outliers.extend(Statistics)

p without_outliers.mean

baseline = without_outliers.mean

g = Gruff::Line.new(480)
g.title = "Change in subscriber count by week" 

g.labels = (0...data.length).each_with_object({}) { |i,h| h[i] = i.to_s }
g.x_axis_label = "Week Number"

g.hide_legend = true
g.data("Subscribers", data)
g.baseline_value = baseline

g.write('change_in_subscribers.png') 
