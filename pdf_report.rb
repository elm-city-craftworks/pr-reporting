require "prawn"
require "prawn/measurement_extensions"

data = [["2011.08.23", 1, 49,  0],
        ["2011.08.30",  2, 69,  20],
        ["2011.09.06",  3, 74,   5],
        ["2011.09.13",  4, 91,  17],
        ["2011.09.20",  5, 101, 10],
        ["2011.09.27",  6, 110,  9],
        ["2011.10.04",  7, 173, 63],
        ["2011.10.11",  8, 186, 13],
        ["2011.10.19",  9, 197, 11],
        ["2011.10.27", 10, 221, 24],
        ["2011.11.02", 11, 230,  9],
        ["2011.11.09", 12, 242, 12]]

header = ["Date", "Issue Number", "Total Subscribers", "Change in Subscribers"]

Prawn::Document.generate("report.pdf", :page_layout   => :landscape,
                                       :top_margin => 1.in, 
                                       :bottom_margin => 1.in) do

  float do
    image(open("subscribers_by_week.png"), :width => (bounds.width / 2)*0.75,
          :position => :right)

    move_down 0.5.in

    image(open("change_in_subscribers.png"), 
          :width => (bounds.width / 2)*0.75, 
          :position => :right)
  end

  text "Practicing Ruby Weekly Report", :size => 24
  text "This report summarizes the subscriber count and change in\n"+
       "subscriber count over the last 12 weeks"

  move_down 0.75.in

  table([header]+data) do |t|
    t.header = true
    t.style(t.columns(1..-1)) { |c| c.align = :right }
  end
end
