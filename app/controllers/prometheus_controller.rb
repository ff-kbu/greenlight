class PrometheusController < ApplicationController
  def index
    meetings = all_running_meetings[:meetings].map  do |m|
      {
          :phone => att(m).select { |a| a[:role] == 'DIAL-IN-USER'}.count,
          :video => att(m).select { |a| a[:hasVideo] == 'true'}.count,
          :total => att(m).count
      }
    end.sort_by { |m| m[:total]  }

    @biggest = meetings.last

    @meeting_count = meetings.count
    @totals = {
        :phone => meetings.map{|m| m[:phone]}.sum,
        :video => meetings.map{|m| m[:video]}.sum,
        :total => meetings.map{|m| m[:total]}.sum
    }

    @greenlight = {
        :rooms => Room.count,
        :users => User.count
    }

    render '/prometheus/index.text.erb', layout: false, content_type: 'text/plain'
  end

  private
  def att(meeting)
    logger.warn ("attendees in meeting #{meeting[:attendees]}")
    logger.warn ("attendees in meeting (2) #{meeting[:attendees][:attendee]}")
    attendees = meeting[:attendees][:attendee]
    unless attendees.kind_of?(Array)
      attendees = [attendees]
    end
    attendees
  end
end
