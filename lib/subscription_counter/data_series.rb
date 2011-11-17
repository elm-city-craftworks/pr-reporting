# While `Campaign.all` grabs all campaign dates and subscriber counts for a
# given mailing list, my report actually target the last N campaigns 
# (roughly corresponding to weeks in
# Practicing Ruby's case). I created this `DataSeries` object to deal with that
# issue as well as to provide a bit of a bufferzone between the code that
# interacts with the [MailChimp API](http://apidocs.mailchimp.com/) and the rest 
# of the system. This in theory will make it easier for me to pull from other 
# data sources in the future, and also makes testing easier.
module SubscriptionCounter
  class DataSeries
    
    # <hr/>
    
    # Like most Ruby collections, the `DataSeries` object mixes in the `Enumerable`
    # module. While in this particular application I only use this for the `map`
    # method, it would be surprising to provide just `map` and not the rest of
    # what `Enumerable` provides.
    
    include Enumerable

    # <hr/>

    # While `DataSeries` is meant to be used with an array of `Campaign`
    # objects, the dependency is implicit and other objects could easily be
    # substituted. This is by design.
    #
    # Using `each_cons` combined with `map` to traverse the campaign list is a 
    # handy way to simultaneously create a new `DataPoint` object for the current
    # campaign while also keeping track of the one that immediately
    # preceded it. Because this report covers both the current subscriber count
    # for any given week as well as the change in subscriber count since the
    # previous week, we need to keep track of this information. This explains
    # why we end up looking at `num_weeks+1` rather than `num_weeks` worth of
    # context.
    # 
    # Additionally, by introducing the `DataPoint` object, we make it so that the rest of
    # our report is completely independent of the MailChimp dependency and
    # the "campaign" vocabulary.
    #
    # Note that each `DataPoint` is assigned a campaign number which corresponds
    # to Practicing Ruby issue numbers. While it's a bit awkward to do this
    # logic here, it's even more awkward to do it elsewhere, so this is where it
    # ended up.
    def initialize(campaigns, num_weeks)
      campaign_number = campaigns.size - num_weeks


      @data = campaigns.last(num_weeks+1).each_cons(2).map do |last, current|
        campaign_number += 1

        DataPoint.new(:number => campaign_number, 
                      :date   => current.date.strftime("%Y.%m.%d"), 
                      :count  => current.subscriber_count,
                      :delta  => current.subscriber_count - last.subscriber_count)
      end 
    end

    # <hr/>

    # This is pretty much the standard boilerplate that comes along with
    # mixing in the `Enumerable` method. Every time I type this I wish there was
    # some nice shortcut to it ;)
    def each
      data.each { |e| yield(e) }
    end

    # <hr/>

    # STYLE POINT: As mentioned in the discussion of [Campaign](campaign), 
    # I have been experimenting with making private accessors for values that I use
    # internally but not externally. Still not sure how I feel about this
    # approach.
    private

    attr_reader :data
  end
end

# <hr/>

# *NOTE:  If you're doing a guided walkthrough of this codebase,
# check out the [DataPoint](data_point.html) object next.
# Or if you'd prefer to jump around, head back to the [project overview](http://elm-city-craftworks.github.com/pr-reporting/lib/subscription_counter.html)
# for an outline of all of the objects in this system.*  
