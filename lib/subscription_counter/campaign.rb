# The `Campaign` object is the only part of this application which interacts
# directly with MailChimp, using [Hominid](https://github.com/terra-firma/hominid) to do so. `Campaign` objects 
# are processed by the [DataSeries](data_series.html) object only,
# and are decoupled from the rest of the application. 
#
# The name "Campaign" is used here because that's what MailChimp calls the emails
# it sends. Personally I find that to stink a bit of marketing speak, but it's
# the right word to use to model this domain, I suppose :-/
module SubscriptionCounter
  class Campaign
    # <hr/>
    
    # Calling `Campaign.all` fetches all the campaigns in MailChimp for
    # the list reference by `MAILCHIMP_SETTINGS[:list_id]`
    #
    # Once the raw campaign data is provided by MailChimp, the data
    # gets normalized slightly and then transformed into `Campaign` 
    # instances. 
    #
    # To make life easier later, the list of campaigns is sorted by date at this time. 
    # Note that this makes use of the `Campaign#<=>` method automatically: Ruby is 
    # smart like that.
    def self.all
      api  = Hominid::API.new(MAILCHIMP_SETTINGS[:api_key])
      data = api.campaigns(:list_id => MAILCHIMP_SETTINGS[:list_id])["data"]
      
      campaigns = data.map do |e|
        new(:api  => api, 
            :id   => e["id"], 
            :date => Date.parse(e["send_time"]))
      end
     
      campaigns.sort 
    end

    # <hr/>
    
    # Because `Campaign.new` is not meant to be called directly, I inject
    # the `Hominid::API` object without providing any sort of default. I use
    # `Hash#fetch` instead of `Hash#[]` here to make it so that an error will be
    # raised if you leave out any of the required parameters. This is helpful
    # in debugging, and can be useful for catching typos as well.
    def initialize(params)
      @api  = params.fetch(:api)
      @id   = params.fetch(:id)
      @date = params.fetch(:date)
    end

    attr_reader :date

    # <hr/>
     
    # By implementing the `<=>` operator, a list of campaign objects (such as
    # the one in `Campaign.all)` can be sorted implicitly by date. Often times
    # when you implement `<=>`, you will also want to `include Comparable`, but
    # in this case it doesn't make much sense to mix in its methods.
    def <=>(other)
      date <=> other.date
    end

    # <hr/>
    
    # MailChimp's API has a cool, if a bit cumbersome API for filtering lists of
    # subscribers. The `subscriber_count` code matches active subscribers who 
    # are not marked as members of the "Free Subscription" group and have 
    # joined Practicing Ruby before the date of the current campaign. 
    # The `campaign_segment_test` call provides a simple count of how many 
    # subscribers match that filter, which is exactly what is needed for this 
    # report.
    #
    # Rudimentary caching is used here to prevent redundant calls to the
    # MailChimp API.
    def subscriber_count
      return @count if @count

      conditions = [{:field => "date", :op => "lt", :value => id},
                    {:field => "interests-#{MAILCHIMP_SETTINGS[:grouping_id]}", 
                     :op    => "none", 
                     :value => "Free Subscription"}]

      @count = api.campaign_segment_test MAILCHIMP_SETTINGS[:list_id], 
                                         :match      => "all", 
                                         :conditions => conditions 
    end

    # <hr/>
    #
    # STYLE POINT: I like to avoid referencing instance variables in all places except for
    # my constructor and explicitly defined setter methods. However, it seems
    # like a bad idea to define public accessors for data that won't be used by
    # the consumer. So lately I've been defining private accessors. I am still
    # not sure if the break from conventions is justified for such a small API
    # difference. Comments welcome!
    private 

    attr_reader :api, :id
  end
end

# <hr/>
#
# *NOTE: If you're doing a guided walkthrough of this codebase,
# check out the [DataSeries](data_series.html) object next.
# Or if you'd prefer to jump around, head back to the [project overview](http://elm-city-craftworks.github.com/pr-reporting/lib/subscription_counter.html)
# for an outline of all of the objects in this system.* 
