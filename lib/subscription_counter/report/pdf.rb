module SubscriptionCounter
  class Report
    class PDF
      include Prawn::Measurements

      def initialize(report)
        @report   = report
        @document = Prawn::Document.new(:page_layout   => :landscape,
                                        :top_margin    => in2pt(1),
                                        :bottom_margin => in2pt(1))

        @document.float { draw_graphs }

        draw_header
        draw_summary_table
      end

      def save_as(filename)
        document.render_file(filename)
      end

      private

      attr_reader :report, :document

      def draw_header
        @document.text "Practicing Ruby Weekly Report", :size => 24
        @document.text "This report summarizes the subscriber count and "+
                       "change in\nsubscriber count over time."

        @document.move_down(in2pt(0.75))
      end

      def draw_summary_table
        header = ["Date",              "Issue Number", 
                  "Total Subscribers", "Change in Subscribers"]

        body   = report.table(:date,:number,:count,:delta)

        @document.table([header]+body) do |t|
          t.header = true
          t.style(t.columns(1..-1)) { |c| c.align = :right }
        end
      end

      def draw_graphs
        image_options = { :width    => (@document.bounds.width / 2)*0.75,
                          :position => :right }

        Dir.mktmpdir do |dir|
          @document.image(weekly_total_graph(dir), image_options)

          @document.move_down(in2pt(0.5))

          @document.image(weekly_change_graph(dir), image_options)
        end
      end

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
    end
  end
end
