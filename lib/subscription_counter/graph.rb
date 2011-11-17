module SubscriptionCounter
  Graph = Object.new
  
  class << Graph
    def build(params)    
      data   = params.fetch(:data)
      labels = params.fetch(:labels) 

      r = RSRuby.instance

      r.png(params.fetch(:file), :width => 400, :height => 300) 

      r.plot(:x     => data,
             :type  => "o",         
             :col   => "blue",     
             :main  => params.fetch(:title),
             :xlab  => "Week Number", 
             :ylab  => "Subscribers",
             :xaxt  => "n")    

      if baseline = params[:baseline]
        r.abline(:h => baseline, :col => "red",:lty => "dotted")
      end

      r.axis(:side => 1, :labels => labels, 
                         :at     => labels.each_index.map { |i| i + 1 })
      r.eval_R("dev.off()")                      
    end
  end
end
