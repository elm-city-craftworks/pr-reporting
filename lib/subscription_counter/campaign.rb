class SubscriptionCounter
  class Campaign
    include Comparable

    def self.all
      api = Hominid::API.new(MailChimp::SETTINGS[:api_key])

      data = api.campaigns(:list_id => MailChimp::SETTINGS[:list_id])["data"]
      
      data.map { |e|
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
      conditions = [{:field => "date", :op => "lt", :value => id},
                    {:field => "interests-#{MailChimp::SETTINGS[:grouping_id]}", 
                     :op    => "none", 
                    :value => "Free Subscription"}]

      api.campaign_segment_test MailChimp::SETTINGS[:list_id], 
        :match      => "all", 
        :conditions => conditions 
    end

    private 

    attr_reader :api, :id
  end
end
