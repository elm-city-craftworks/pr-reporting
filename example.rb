require_relative "lib/subscription_counter"

campaigns = SubscriptionCounter::Campaign.all

counter   = SubscriptionCounter.new(campaigns, 10)
report    = SubscriptionCounter::Report.new(counter)

SubscriptionCounter::Report::PDF.new(report).save_as("foo.pdf")
