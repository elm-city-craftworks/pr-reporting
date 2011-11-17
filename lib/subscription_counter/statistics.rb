class SubscriptionCounter
  Statistics = Object.new

  Statistics.instance_eval do
    def mean(list)
      list.reduce(:+) / list.length.to_f
    end

    def sample_variance(list)
      avg = mean(list)
      sum = list.reduce(0) { |acc,i| acc + (i-avg)**2 }

      return sum / (list.length.to_f - 1)
    end

    def standard_deviation(list)
      Math.sqrt(sample_variance(list))
    end

    # Take a list and compute its standard deviation
    # and mean, and then uses this information to reject
    # outliers from the original list. Finally, compute
    # the mean of the adjusted list.
    def adjusted_mean(list)
      mean    = mean(list)
      std_dev = standard_deviation(list)

      lower_limit = mean - std_dev
      upper_limit = mean + std_dev

      list_without_outliers = list.select do |e|
        (lower_limit..upper_limit).include?(e)
      end

      mean(list_without_outliers)
    end

    # Takes a list and computes the difference between
    # each consecutive pair of values, returning a new
    # list with the results
    def deltas(list)
      list.each_cons(2).map { |a,b| b - a }
    end
  end
end
