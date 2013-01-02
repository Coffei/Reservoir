class HomeController < ApplicationController
  DATETIME_FORMAT = Time::DATE_FORMATS[:date_time_nosec]
  
  def index
    @search = Reservation.new if !defined?(@search)
    @best_rooms = Room.joins("LEFT OUTER JOIN reservations ON reservations.room_id = rooms.id").group("rooms.id, rooms.name, rooms.capacity, rooms.location, rooms.equipment, rooms.created_at, rooms.updated_at")
                      .where("reservations.\"end\" >= ? AND reservations.\"start\" <= ?", DateTime.now.to_s(:db), (DateTime.now + 14.days).to_s(:db))
                      .order("count(reservations.id) DESC")
                      .limit(params[:limit_room]? params[:limit_room].to_i : 5)
    @last_reservations = Reservation.order("created_at DESC").limit(params[:limit_res]? params[:limit_res].to_i : 5)
  end
  
  def search
    
    error = false
    
    begin
      @search = Reservation.new(params[:reservation])
      @search.start = DateTime.strptime(params[:reservation][:start_string], DATETIME_FORMAT) - DateTime.local_offset
      @search.end = DateTime.strptime(params[:reservation][:end_string], DATETIME_FORMAT) - DateTime.local_offset
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
      @rooms = Room.where("rooms.id NOT IN (SELECT reservations.room_id FROM reservations WHERE reservations.room_id = rooms.id AND reservations.\"end\" >= ? AND reservations.\"start\" <= ?)",
                          @search.start, @search.end).order("name ASC")
     
     respond_to do |format|
       format.html
       format.json { render json: @rooms }
     end
     
    end
   
  end
end

