class SubscriptionCounter
  class WeekStats
    def initialize(params)
      @issue_number     = params.fetch(:issue_number)
      @date             = params.fetch(:date)
      @subscriber_count = params.fetch(:subscriber_count)
    end

    attr_reader :issue_number, :date, :subscriber_count
  end
end
