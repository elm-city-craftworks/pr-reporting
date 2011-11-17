module SubscriptionCounter
  class Report
    def initialize(series)
      @series = series

      @issue_numbers = series.map(&:number)
      @weekly_counts = series.map(&:count)
      @weekly_deltas = series.map(&:delta)
      @average_delta = Statistics.adjusted_mean(@weekly_deltas)
    end

    def table(*fields)
      @series.map { |e| fields.map { |f| e.send(f) } }
    end

    attr_reader :issue_numbers, :weekly_counts, :weekly_deltas, 
                :average_delta, :summary
  end
end
