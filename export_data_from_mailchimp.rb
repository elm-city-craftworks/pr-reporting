require "hominid"
require "date"

require_relative "config/mailchimp_settings"

h = Hominid::API.new(MailChimp::SETTINGS[:api_key])

campaigns = h.campaigns["data"].map { |e| [e["id"], Date.parse(e["send_time"]) ] }.
              sort_by { |id,date| date }


campaigns.each do |campaign_id, date|
  subscribers = h.campaign_segment_test(MailChimp::SETTINGS[:list_id], 
    :match      => "all", 
    :conditions => [{:field => "date", :op => "lt", :value => campaign_id},
                    {:field => "interests-#{MailChimp::SETTINGS[:grouping_id]}", 
                     :op    => "none", 
                     :value => "Free Subscription"}]
  )
  p [date.strftime("%Y.%m.%d"), subscribers]
end
