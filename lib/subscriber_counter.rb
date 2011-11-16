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

  def initialize(weeks_of_context)
    api = Hominid::API.new(MailChimp::SETTINGS[:api_key])

    campaign_data = api.campaigns["data"]
                       .map { |e| [ e["id"], Date.parse(e["send_time"])] }
                       .sort_by { |id,date| date }

    campaign_count = campaign_data.size
        
    @data = (campaign_count-weeks_of_context).upto(campaign_count-1).map do |i|
      campaign_id, date = campaign_data[i]
      subscribers = api.campaign_segment_test(MailChimp::SETTINGS[:list_id], 
        :match      => "all", 
        :conditions => [{:field => "date", :op => "lt", :value => campaign_id},
                        {:field => "interests-#{MailChimp::SETTINGS[:grouping_id]}", 
                         :op    => "none", 
                         :value => "Free Subscription"}]
      )

      WeekStats.new(:issue_number     => i+1, 
                    :date             => date.strftime("%Y.%m.%d"), 
                    :subscriber_count => subscribers)
    end
  end

  def each
    @data.each { |e| yield(e) }
  end
end

=begin
counter = SubscriberCounter.new(12)

p counter.map { |e| [e.issue_number, e.subscriber_count] }
=end
