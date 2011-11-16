require_relative "lib/subscription_counter"

counter = SubscriptionCounter.new(SubscriptionCounter::Campaign.all, 12)

p counter.map { |e| [e.issue_number, e.subscriber_count] }

issue_numbers     = counter.map(&:issue_number)
subscriber_counts = counter.map(&:subscriber_count)

graph = SubscriptionCounter::Graph.new(
           :title  => "Subscriber count by week",
           :labels => issue_numbers,
           :data   => subscriber_counts)

graph.save_as("weekly_count.png")
