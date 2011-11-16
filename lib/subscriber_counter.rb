require "hominid"
require "date"

require_relative "../config/mailchimp_settings"

class SubscriberCounter
  class WeekStats
    def initialize(params)
      @issue_number     = params.fetch(:issue_number)
      @date             = params.fetch(:date)
      @subscriber_count = params.fetch(:subscriber_count)
    end

    attr_reader :issue_number, :date, :subscriber_count
  end

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

class Campaign
  include Comparable

  def self.all
    api = Hominid::API.new(MailChimp::SETTINGS[:api_key])

    api.campaigns(:list_id => MailChimp::SETTINGS[:list_id])["data"].map { |e|
      new(:api => api, :id => e["id"], :date => Date.parse(e["send_time"]))
    }.sort 
  end

  def initialize(params={})
    @api  = params.fetch(:api)
    @id   = params.fetch(:id)
    @date = params.fetch(:date)
  end

  attr_reader :date

  def <=>(other)
    date <=> other.date
  end

  def subscriber_count
    api.campaign_segment_test(MailChimp::SETTINGS[:list_id], 
      :match      => "all", 
      :conditions => [{:field => "date", :op => "lt", :value => id},
                      {:field => "interests-#{MailChimp::SETTINGS[:grouping_id]}", 
                       :op    => "none", 
                       :value => "Free Subscription"}]
    )
  end

  private 

  attr_reader :api, :id
end


=begin
counter = SubscriberCounter.new(Campaign.all, 6)

p counter.map { |e| [e.issue_number, e.subscriber_count] }
=end
