# `DataPoint` objects are simple structures which are similar to
# [Campaign](campaign.html) objects, but not tied to the 
# [MailChimp API](http://apidocs.mailchimp.com) in any way. This object
# implements part of the interface that the [Report](report.html) object 
# implicitly depends upon, and every [DataSeries](data_series.html) object is
# simply a collection of `DataPoint` objects under the hood.
module SubscriptionCounter
  class DataPoint
    # <hr/>
    
    # While `DataPoint.new` is unlikely to be called directly by anything except
    # `DataSeries`, it's a good habit to use `Hash#fetch` here to indicate that all
    # `params` are mandatory. This will catch typos or misuses of the API
    # easily.
    def initialize(params)
      @number = params.fetch(:number)
      @date   = params.fetch(:date)
      @count  = params.fetch(:count)
      @delta  = params.fetch(:delta)
    end

    attr_reader :number, :date, :count, :delta
  end
end

# <hr/>

# *NOTE: If you're doing a guided walkthrough of this codebase,
# check out the [Report](report.html) object next.
# If you'd prefer to jump around instead, head back to the [project overview](http://elm-city-craftworks.github.com/pr-reporting/lib/subscription_counter.html)
# for an outline of all of the objects in this system.*  
