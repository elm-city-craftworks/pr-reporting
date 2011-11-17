# The `Statistics` object is a thin wrapper over a computation that my report
# uses to guess at what the average change in subscriber count per week is. It
# originally used a lot more code than what it currently does, but now that this
# report uses R for graphing, I decided to use it for computing the mean and
# standard deviation of datasets as well.
module SubscriptionCounter
  Statistics = Object.new

  class << Statistics 

    # <hr/>
    
    # The `adjusted_mean` method takes an array of numbers and computes its mean
    # and standard deviation. This information is used to determine which points
    # should be treated as outliers and removed from the dataset.
    #
    # The reason I implemented this function is that it isn't uncommon for
    # Practicing Ruby to see a huge bump when it gets mentioned somewhere, but
    # the change in subscribers in that pariticular week won't be nearly 
    # representative of the "average week".I want to use average subscriber
    # increase as a metric for how well Practicing Ruby is growing, but I don't
    # want have false expectations about its growth rate due to outliers.
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

# <hr/>

# *NOTE: If you're doing a guided walkthrough of this codebase,
# check out the [Graph](graph.html) object next.
# Or if you'd prefer to jump around, head back to the [project overview](http://elm-city-craftworks.github.com/pr-reporting/lib/subscription_counter.html)
# for an outline of all of the objects in this system.* 
