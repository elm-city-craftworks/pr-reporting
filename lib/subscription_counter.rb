# This annotated codebase is meant to serve as [Practicing Ruby](http://practicingruby.com) *Issue 2.13*. 
# While the typical Practicing Ruby issue is published in article format, the subject matter 
# for this issue seemed to fit a literate-programming format better.

# In this issue, I'll discuss how I implemented the code necessary to generate
# [this PDF report](http://practicingruby.com/practicing_ruby_stats.pdf).
# Business reporting can be tricky in Ruby, and even modest reporting
# tasks demand a non-trivial amount of software design consideration.

# Rather than trying to come up with some general guidelines for how to approach
# reporting problems in Ruby, I decided it might be interesting to attack a real
# problem of mine, clean up my code as much as possible, and share the results.
# Please be sure to let me know what you think!

# The *subcription_counter.rb* file you're looking at now is the entry point 
# into this project, and it's where I've stacked all the necessary requires to 
# get a fully running application. Typically I break things out starting with 
# the standard libraries I'm using, followed by the third party libraries, 
# then lastly my project files. This gives me a nice way to see the 
# dependencies of the entire project at glance.

# <hr/>

# While my external dependencies almost certainly load more stdlibs, this report 
# only explicitly depend on the _date_ and _tempfile_ libraries.

require "date"
require "tempfile"

# <hr/>

# As for external dependencies: I make use of [RSRuby](https://github.com/alexgutteridge/rsruby) 
# to integrate with the [R programming language](http://www.r-project.org/) for graphing 
# and basic stats computations, [Hominid](https://github.com/terra-firma/hominid) 
# for integrating with the [MailChimp API](http://apidocs.mailchimp.com/api/), and 
# [Prawn](http://github.com/sandal/prawn) for PDF generation.

require "rsruby"
require "hominid"
require "prawn"

# <hr/>

# I define some values in the *mailchimp_settings.rb* file and 
# reference them later via the 
# `SubscriptionCounter::MAILCHIMP_SETTINGS` constant. Because this
# is just a boring hash of API keys and other database ids, you can
# safely treat it as a black box.

require_relative "../config/mailchimp_settings"

# <hr/>

# I did what I could to make this code as modular as possible. The list below
# outlines the different objects this system is made up of, and what their
# respective jobs are.
#
# * [Campaign](subscription_counter/campaign.html) integrates
# with MailChimp to pull down subscriber counts and dates for each campaign.
# * [DataSeries](subscription_counter/data_series.html) and
#   [DataPoint](subscription_counter/data_point.html) are
#   the data structures that I normalize the MailChimp data into. The goal in
#   creating them was to make it possible for the report to be reasonably
#   decoupled from `SubscriptionCounter::Campaign` so that I could load this
#   same data from a different representation down the line (such as a CSV
#   file).
# * [Graph](subscription_counter/graph.html) is a simple singleton object that
#   wraps the R plotting functions I use. 
# * [Statistics](subscription_counter/statistics.html) is another singleton 
#   object which uses R to implement an adjusted average computation that
#   I use in this report.
# * [Report](subscription_counter/report.html) is an adapter object which
#   transforms a `DataSeries` object into data that is convenient to work
#   with in formatted output.
# * [Report::PDF](subscription_counter/report/pdf.html) generates a nicely
#   formatted representation of the data contained in the `Report`

require_relative "subscription_counter/campaign"
require_relative "subscription_counter/data_point"
require_relative "subscription_counter/data_series"
require_relative "subscription_counter/graph"
require_relative "subscription_counter/statistics"
require_relative "subscription_counter/report"
require_relative "subscription_counter/report/pdf"

# <hr/>
#
# *NOTE: If you start with the [Campaign](subscription_counter/campaign.html)
# object and follow the breadcrumbs at the end of each page, you should be able
# to get a nice comprehensive walkthrough of this codebase.*
