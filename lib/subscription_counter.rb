require "date"

require "hominid"
require "gruff"

require_relative "../config/mailchimp_settings"  

require_relative "subscription_counter/campaign"
require_relative "subscription_counter/week_stats"
require_relative "subscription_counter/graph"

class SubscriptionCounter
  include Enumerable

  def initialize(data, weeks_of_context)
    campaign_count = data.size
        
    @data = (campaign_count-weeks_of_context).upto(campaign_count-1).map do |i|
      campaign = data[i]

      WeekStats.new(:issue_number     => i+1, 
                    :date             => campaign.date.strftime("%Y.%m.%d"), 
                    :subscriber_count => campaign.subscriber_count)
    end
  end

  def each
    @data.each { |e| yield(e) }
  end
end
