class HomeController < ApplicationController
  DATETIME_FORMAT = Time::DATE_FORMATS[:date_time_nosec]
  
  def index
    @search = Reservation.new(start_string: Time.now.to_s(:date_time_nosec), end_string: (Time.now + 30.minutes).to_s(:date_time_nosec)) if !defined?(@search)
    
    now = Time.zone.now
    @reservations_running = Reservation.all_occurrences(Reservation.between(now, now), after: now, until: now)
    @reservations_running.concat(TempReservation.all_occurrences(TempReservation.between(now, now), after: now, until: now))
    @reservations_running.sort_by! {|res| res.start }
    @reservations_running = @reservations_running.take(10)
    
    if(@reservations_running.empty?)
      @free_rooms = Room.all
    else
      @free_rooms = Room.where("id NOT IN (?)", @reservations_running.map(&:room_id)).order("name ASC")
    end
  end
  
  def search
    error = false
    begin
      @search = Reservation.new(params[:reservation])
      @search.start = Time.zone.at((DateTime.strptime(params[:reservation][:start_string], DATETIME_FORMAT) - DateTime.local_offset).to_i)
      @search.end = Time.zone.at((DateTime.strptime(params[:reservation][:end_string], DATETIME_FORMAT) - DateTime.local_offset).to_i)
      error = !@search.valid?
    rescue ArgumentError
      @search.errors.add(:start_string,"")
      @search.errors.add(:end_string,"")
      error = true
    end
    
    if error
      index
      render action: "index"
    else
      
      reservations = Reservation.all_occurrences(Reservation.between(@search.start,@search.end), after: @search.start, until: @search.end)
      reservations.concat(TempReservation.all_occurrences(TempReservation.between(@search.start,@search.end), after: @search.start, until: @search.end))
      occupied_rooms_ids = reservations.map(&:room_id).uniq
      
      if(occupied_rooms_ids.empty?)
        @rooms = Room.all
      else
        @rooms = Room.where("id NOT IN (?)", occupied_rooms_ids)
      end
      
      respond_to do |format|
        format.html
        format.json { render json: @rooms }
      end
     
    end
   
  end
end

