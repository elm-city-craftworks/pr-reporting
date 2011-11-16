require "hominid"
require "date"

require_relative "../config/mailchimp_settings"

h = Hominid::API.new(MailChimp::SETTINGS[:api_key])

campaigns = h.campaigns["data"].map { |e| [e["id"], Date.parse(e["send_time"]) ] }.
              sort_by { |id,date| date }

campaign_count = campaigns.size


(campaign_count-12).upto(campaign_count-1) do |i|
 campaign_id, date = campaigns[i]
  subscribers = h.campaign_segment_test(MailChimp::SETTINGS[:list_id], 
    :match      => "all", 
    :conditions => [{:field => "date", :op => "lt", :value => campaign_id},
                    {:field => "interests-#{MailChimp::SETTINGS[:grouping_id]}", 
                     :op    => "none", 
                     :value => "Free Subscription"}]
  )
  p [i+1, date.strftime("%Y.%m.%d"), subscribers]
end
