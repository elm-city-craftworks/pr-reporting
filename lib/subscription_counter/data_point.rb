class SubscriptionCounter
  class DataPoint
    def initialize(params)
      @number = params.fetch(:number)
      @date   = params.fetch(:date)
      @count  = params.fetch(:count)
      @delta  = params.fetch(:delta)
    end

    attr_reader :number, :date, :count, :delta
  end
end
