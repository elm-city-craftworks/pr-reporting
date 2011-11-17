# `Graph` provides a very thin wrapper over calls to the R programming language,
# via [RSRuby](https://github.com/alexgutteridge/rsruby). It is mostly full of
# hardcoded values, and would need to be generalized in order to be used as a
# general purpose graph generation object. The only reason it is currently
# extracted into its own object is to allow [Report::PDF](report/pdf.html) to
# reference an internal API rather than an external one.
#
# While that may seem of limited benefit, I ended up attempting to use several 
# different graphing libraries while working on this report. I first started
# working with Gruff, and then attempted to switch to Google Charts after
# finding a bug in the way Gruff draws baselines. Unfortunately, Google Charts
# had similarly confusing issues, and so I didn't settle on using R until my
# third attempt.
#
# Because this is a brand new system, changing the graphing engine would be easy
# whether or not an extraction existed for it. However, as this system grows and
# changes, it will get increasingly hard to make those sort of switches if they
# weren't accounted for early on in its design. This is why it rarely hurts to
# create an internal API wrapping an external dependency, even if that wrapper
# is not doing much to generalize your code.
module SubscriptionCounter
  Graph = Object.new

  class << Graph
  # <hr/>

  # The `Graph#build` consists mostly of bits and pieces I've cargoculted from
  # reading various posts about how to generate graphs in R. It goes without
  # saying that R has a pretty weird way of doing things, but it also happens
  # to be incredibly flexible.
  #
  # To generate a graph, _data_ and _labels_ must be provided, as well as a
  # _title_. If a _baseline_ is provided, a horizontal dotted line will be drawn 
  # at the specified position. I made _baseline_ an optional parameter because
  # having an explicitly marked baseline makes sense for one of the graphs in
  # this report but not the other.
  #
  # ASIDE: While I'm not an experienced R programmer, 
  # I am pretty sure the way this
  # code works is by setting the rendering surface to be a PNG file instead of
  # the windowing system which R would typically write its graphs to. This
  # explains the cryptic `dev.off()` call which finalizes writing the file.
  #
  # The most awkward thing I've found about any way of working with graphs in
  # Ruby is the way axis labeling is handled. From what I've seen, R provides
  # the most sensible defaults when it comes to step sizes and min/max values,
  # but it still involves a bit of manual futzing around to get things to work
  # cleanly.
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

# <hr/>

# *NOTE: If you're doing a guided walkthrough of this codebase,
# check out the [Report::PDF](report/pdf.html) object next.
# Or if you'd prefer to jump around, head back to the [project overview](/pr-reporting/lib/subscription_counter.html)
# for an outline of all of the objects in this system.* 
