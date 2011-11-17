module SubscriptionCounter
  Statistics = Object.new

  class << Statistics 
    # Take a list and compute its standard deviation
    # and mean, and then uses this information to reject
    # outliers from the original list. Finally, compute
    # the mean of the adjusted list.
    def adjusted_mean(list)
      r = RSRuby.instance

      mean    = r.mean(list)
      std_dev = r.sd(list)

      lower_limit = mean - std_dev
      upper_limit = mean + std_dev

      list_without_outliers = list.select do |e|
        (lower_limit..upper_limit).include?(e)
      end

      r.mean(list_without_outliers)
    end
  end
end
