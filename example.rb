require_relative "lib/subscription_counter"

counter = SubscriptionCounter.new(SubscriptionCounter::Campaign.all, 12)

weekly_change = SubscriptionCounter::WeeklyChange.new(counter)

graph = SubscriptionCounter::Graph.new(
           :title  => "Change in subscribers by week",
           :labels => weekly_change.issue_numbers,
           :data   => weekly_change.weekly_counts)

graph.save_as("weekly_count.png")
