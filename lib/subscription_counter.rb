require "date"
require "tempfile"

require "rsruby"
require "hominid"
require "prawn"

require_relative "../config/mailchimp_settings"  

require_relative "subscription_counter/campaign"
require_relative "subscription_counter/data_point"
require_relative "subscription_counter/graph"
require_relative "subscription_counter/statistics"
require_relative "subscription_counter/report"
require_relative "subscription_counter/report/pdf"

class SubscriptionCounter
  include Enumerable

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

  def each
    @data.each { |e| yield(e) }
  end
end
