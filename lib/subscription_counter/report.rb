class SubscriptionCounter
  class Report
    def initialize(counter)
      @counter       = counter

      @issue_numbers = counter.map(&:number)
      @weekly_counts = counter.map(&:count)
      @weekly_deltas = counter.map(&:delta)
      @average_delta = Statistics.adjusted_mean(@weekly_deltas)
    end

    def table(*fields)
      @counter.map { |e| fields.map { |f| e.send(f) } }
    end

    attr_reader :issue_numbers, :weekly_counts, :weekly_deltas, 
                :average_delta, :summary
  end
end
