# The `Report` object serves as a bridge between the data model and the
# presentation layer by extracting data from  [DataSeries](data_series.html)
# objects and transforming them into a format that is convenient for 
# formatting objects to work with.
module SubscriptionCounter
  class Report
    # <hr/>

    # While `Report` is meant to be used with a `DataSeries` object, the
    # dependency is implicit and other objects could be subsituted without too
    # much effort. This is by design.
    #
    # The way this code generates the `issue_numbers`, `weekly_counts`, and
    # `weekly_deltas` lists causes multiple passes through the series data
    # unnecessarily. That said, with a tiny dataset I generally am willing to
    # sacrifice a bit of efficiency in the name of clear and concise code. 
    #
    # The `average_delta` computation is used by one of the report's graphs
    # to display a baseline representing the average number of new subscribers
    # gained each week, after outliers have been removed. Check out the
    # [Statistics](statistics.html) object if you want to see how this
    # computation is implemented, but feel free to treat it as a blackbox
    # otherwise
    #
    def initialize(series)
      @series = series

      @issue_numbers = series.map(&:number)
      @weekly_counts = series.map(&:count)
      @weekly_deltas = series.map(&:delta)
      @average_delta = Statistics.adjusted_mean(@weekly_deltas)
    end
 
    attr_reader :issue_numbers, :weekly_counts, :weekly_deltas, 
                :average_delta, :summary, :series

    # <hr/>
    
    # The `Report#table` method generates a row of data for each `DataPoint` 
    # object in the `DataSeries` collection by accessing the specified 
    # fields in order. This method is used to make table generation 
    # easier in [Report::PDF](report/pdf.html)
    def table(*fields)
      series.map { |e| fields.map { |f| e.send(f) } }
    end
  end
end

# <hr/>

# *NOTE:  If you're doing a guided walkthrough of this codebase,
# check out the [Graph](graph.html) object next.
# Or if you'd prefer to jump around, head back to the [project overview](http://elm-city-craftworks.github.com/pr-reporting/lib/subscription_counter.html)
# for an outline of all of the objects in this system.*  
