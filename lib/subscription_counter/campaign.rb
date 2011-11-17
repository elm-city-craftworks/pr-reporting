module SubscriptionCounter
  class Campaign
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

    def initialize(params)
      @api  = params.fetch(:api)
      @id   = params.fetch(:id)
      @date = params.fetch(:date)
    end

    attr_reader :date

    def <=>(other)
      date <=> other.date
    end

    def subscriber_count
      conditions = [{:field => "date", :op => "lt", :value => id},
                    {:field => "interests-#{MAILCHIMP_SETTINGS[:grouping_id]}", 
                     :op    => "none", 
                     :value => "Free Subscription"}]

      api.campaign_segment_test MAILCHIMP_SETTINGS[:list_id], 
                                :match      => "all", 
                                :conditions => conditions 
    end

    private 

    attr_reader :api, :id
  end
end
