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

  def room_status
    meetings = {}
    all_running_meetings[:meetings].each do |m|
      meetings[m[:meetingID]] =  att(m).count
    end

    @users_in_room = {}
    Room.all.each do |room|
      @users_in_room["#{room.uid}"] = meetings["#{room.bbb_id}"] || 0
    end

    respond_to do |format|
      format.json { render json: @users_in_room.to_json }
      format.any { render '/prometheus/room_status.text.erb', layout: false, content_type: 'text/plain' }
    end
  end

  private
  def att(meeting)
    attendees = meeting[:attendees][:attendee]
    unless attendees.kind_of?(Array)
      attendees = [attendees]
    end
    attendees
  end
end
