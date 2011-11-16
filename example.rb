require_relative "lib/subscription_counter"

counter = SubscriptionCounter.new(SubscriptionCounter::Campaign.all, 12)

p counter.map { |e| [e.issue_number, e.subscriber_count] }
