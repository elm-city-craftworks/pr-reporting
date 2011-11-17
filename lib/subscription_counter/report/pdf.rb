# The `Report::PDF` object is responsible for composing the data provided by a
# `Report` object into a nicely formatted PDF document. It uses
# [Prawn](http://github.com/sandal/prawn) to generate the text and tables, and
# leans on [RSRuby](https://github.com/alexgutteridge/rsruby) via my 
# trivial [Graph](/pr-reporting/lib/subscription_counter/graph.html) wrapper object.
#
# Because the report this implements is meant to represent a fixed amount of
# information at a time, I cut a lot of corners and sized/positioned many of the
# report elements absolutely. Designing reports which need to grow and shrink
# dynamically can be a real challenge, and would require much more clever
# composition than what you see here. Prawn has facilities that make that sort
# of reporting possible, but there is no need to make this particular report any
# more challenging than it already is.

module SubscriptionCounter
  class Report
    class PDF

      # <hr/>

      # Mixing in this module makes it possible to write `in2pt(1)` instead of
      # `Prawn::Measurements.in2pt(1)`. I am generally against doing this sort
      # of thing, but the alternatives are either to use this giant name in many
      # places or enable Prawn's monkeypatches to `Numeric`. Since neither of
      # those options sound good, it is worth it to sacrifice some
      # purity in the name of convenience. However, be sure to note that
      # mixing in a module for the sole purpose of stripping namespaces 
      # is a code smell and should usually be avoided.
      include Prawn::Measurements

      # <hr/>
      
      # When a `Report::PDF` instance is created, all the important drawing
      # operations are executed immediately. The text, tables, and graphs are
      # all drawn, and all that remains to be done is to explicitly write the
      # file via a call to `Report::PDF#save_as`. The current design does not
      # allow for anything useful to happen after a call to `Report::PDF.new`
      # but before a call to `Report::PDF#save_as`, but this API was set up this
      # way by design to leave room for extension points later.
      def initialize(report)
        @report   = report
        @document = Prawn::Document.new(:page_layout   => :landscape,
                                        :top_margin    => in2pt(1),
                                        :bottom_margin => in2pt(1))

        @document.float { draw_graphs }

        draw_header
        draw_summary_table
      end

      # <hr/>
      
      # Because this report is meant to be run standalone, it makes sense to
      # write it to file. However, Prawn also supports writing a PDF to a
      # string, which could be handy if this report needed to be generated on
      # demand in a web application. YAGNI for now though.
      # 
      def save_as(filename)
        document.render_file(filename)
      end

      # <hr/>

      # As mentioned before, I have started experimenting with private accessors
      # in my code. See the discussion in the private section of 
      # [Campaign](/pr-reporting/lib/subscription_counter) for details

      private

      attr_reader :report, :document

      # <hr/>
      
      # The graphs use a hardcoded width of 40% of the page size (not
      # including margins) and separated by some vertical padding. These numbers
      # were arrived at through trial and error, but a better approach would be
      # to use a grid layout, which Prawn supports.
      #
      # Note that this method makes use of `Dir.mktmpdir` to render the graphs
      # into a temporary directory. This makes it possible to embed them within
      # the document and then unlink the entire directory automatically as soon
      # as that is done. Prawn has support for rendering blobs of image data
      # directly, but as of right now `Graph` writes to file. I would have to
      # dig deeper into R to see if there is a way to avoid round tripping from
      # memory to file and back again.
      def draw_graphs
        image_options = { :width    => document.bounds.width * 0.4,
                          :position => :right }

        Dir.mktmpdir do |dir|
          document.image(weekly_total_graph(dir), image_options)

          document.move_down(in2pt(0.5))

          document.image(weekly_change_graph(dir), image_options)
        end
      end

      # <hr/>
      
      # The `weekly_total_graph` method takes a temporary directory to write its
      # image in, and then passes data from the `Report` object into
      # `Graph.build`. No transformations need to be done on the data because
      # `Report` is designed with the needs of this code in mind.
      def weekly_total_graph(dir)
        total_graph_file = "#{dir}/subscribers_by_week.png"

        total_graph = Graph.build(
          :title    => "Total subscribers by week",
          :labels   => report.issue_numbers,
          :data     => report.weekly_counts,
          :file     => total_graph_file
        )
        
        total_graph_file
      end

      # <hr/>

      # The `weekly_change_graph` method works in a similar manner to
      # `weekly_total_graph`. The only notable difference between the two
      # (aside from operating on different data) is that `weekly_change_graph`
      # provides a _baseline_ value to `Graph.build`. This is used to render a
      # dotted horizontal line representing the average change in subscribers
      # over time.
      def weekly_change_graph(dir)
        change_graph_file = "#{dir}/change_by_week.png"

        change_graph = Graph.build(
          :title    => "Change in subscriber count by week",
          :labels   => report.issue_numbers,
          :data     => report.weekly_deltas,
          :baseline => report.average_delta,
          :file     => change_graph_file
        )

        change_graph_file
      end

      
      # <hr/>
      
      # I've rendered the headers on this report in a bit of a ham-handed way.
      # Prawn can handle text wrapping within a column just fine, but because
      # this text is hard coded, I decided to simply embed linebreaks myself.
      # Don't take this approach as a best practice for working with Prawn :)
      def draw_header
        document.text "Practicing Ruby Weekly Report", :size => 24
        document.text "This report summarizes the subscriber count and "+
                       "change in\nsubscriber count over time."

        document.move_down(in2pt(0.75))
      end

      # <hr/>

      # To render the summary table, a header row is added to the array of arrays
      # provided by `Report.table`. All columns except for the date column are
      # numeric, so it makes sense to right align them.
      def draw_summary_table
        header = ["Date",              "Issue Number", 
                  "Total Subscribers", "Change in Subscribers"]

        body   = report.table(:date,:number,:count,:delta)

        document.table([header]+body) do |t|
          t.header = true
          t.style(t.columns(1..-1)) { |c| c.align = :right }
        end
      end
    end
  end
end

# <hr/>

# *NOTE*: If you've been doing the guided walkthrough, congratulations, you've
# made it to the end! You can explore more by [checking out the repository on
# Github](https://github.com/elm-city-craftworks/pr-reporting), or you can return to [practicingruby.com](http://practicingruby.com) and
# leave me a comment. Feedback is welcome!
#
# If instead you've been jumping around, you can go back to the [project 
# overview page](/pr-reporting/lib/subscription_counter.html) for an outline of all the objects in this system.
