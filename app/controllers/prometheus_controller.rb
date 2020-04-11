class PrometheusController < ApplicationController
  def index
    meetings = all_running_meetings[:meetings]
    @meeting_attendees = meetings.map { |m| m[:attendees].count}
    render '/prometheus/index.text.erb', layout: false, content_type: 'text/plain'
  end
end
