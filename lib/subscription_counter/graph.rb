class SubscriptionCounter
  class Graph
    def initialize(params={})
      @graph = Gruff::Line.new(480)
      
      @graph.title         = params.fetch(:title)
      @graph.x_axis_label  = "Week Number"
      @graph.hide_legend   = true
      @graph.labels        = params.fetch(:labels)
                                   .each
                                   .with_index
                                   .with_object({}) { |(e,i),h| h[i] = e.to_s }

      @graph.data("Subscribers", params.fetch(:data))
    end

    def save_as(filename)
      @graph.write(filename)
    end
  end
end
