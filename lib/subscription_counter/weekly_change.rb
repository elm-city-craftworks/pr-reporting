class SubscriptionCounter
  class WeeklyChange
    def initialize(counter)
      @counter = counter
    end

    def issue_numbers
      @counter.issue_numbers[1..-1]
    end

    def weekly_counts
      @counter.weekly_counts.each_cons(2).map { |a,b| b - a }
    end

    def baseline
      13
    end
  end
end
