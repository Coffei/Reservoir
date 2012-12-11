class ReservationsController < ApplicationController
  before_filter :authenticate_user!, except: [:index, :show, :indexByUser, :find, :search]
  DATETIME_FORMAT = Time::DATE_FORMATS[:date_time_nosec]
  
  def index
    @room = Room.find(params[:room_id])
    @reservations = Reservation.of(@room).order("start ASC")
    
    @reservations = @reservations.after(params[:start]) if params[:start]
    @reservations = @reservations.before(params[:end]) if params[:end]
    
    respond_to do |format|
      format.html
      format.js { render :json => @reservations }
      format.json { render :json => @reservations.map { |r| r.as_public_json } }
    end
  end
  
  def indexByUser
    @user = User.find(params[:id])
    
    @reservations = Reservation.where(author_id: @user.id).order("start ASC")
    
    @reservations = @reservations.after(params[:start]) if params[:start]
    @reservations = @reservations.before(params[:end]) if params[:end]
    
    respond_to do |format|
      format.html
      format.js { render :json => @reservations }
      format.json { render :json => @reservations.map { |r| r.as_public_json } }
    end
  end
  
  def show
    @reservation = Reservation.find(params[:id])
    
    respond_to do |format|
      format.html
      format.js { render :json => @reservation }
      format.json { render :json => @reservation.as_public_json }
    end
  end
   
  def create
    @room = Room.find(params[:room_id])
    
    error = false
    
    begin
      @reservation = Reservation.new(params[:reservation])
      @reservation.room = @room
      @reservation.author = current_user
      @reservation.start = DateTime.strptime(params[:reservation][:start_string], DATETIME_FORMAT) - DateTime.local_offset
      @reservation.end = DateTime.strptime(params[:reservation][:end_string], DATETIME_FORMAT) - DateTime.local_offset
      
      error = !@reservation.save
    rescue ArgumentError
      @reservation.errors.add(:start_string,"")
      @reservation.errors.add(:end_string,"")
      error = true
    end
    
    if error
      render action: "new"
    else
      flash[:notice] = "Reservation #{@reservation.summary.html_safe} was created!"
      redirect_to @room
    end
  end
  
  def new
    @room = Room.find params[:room_id]
    @reservation = Reservation.new
  end
  
  def destroy
    reservation = Reservation.find(params[:id])
    
    reservation.destroy
    
    redirect_to reservation.room
    flash[:notice] = "Reservation #{reservation.summary.html_safe} was deleted!"
  end
  
  def destroymany
    @room = Room.find(params[:room_id])
    ids = params[:deleteids].keys
    deleted = []
    
    ids.each do |id|
      reservation = Reservation.find(id)
      reservation.destroy
      
      deleted << reservation.summary
    end
    
    redirect_to room_reservations_path(@room)
    flash[:notice] = "The following reservations were deleted: " + deleted.map() { |text| text.html_safe }.join(", ")
  end
  
  def edit
    @room = Room.find(params[:room_id])
    @reservation = Reservation.find(params[:id])
    @reservation.start_string = @reservation.start.localtime.strftime(DATETIME_FORMAT)
    @reservation.end_string = @reservation.end.localtime.strftime(DATETIME_FORMAT)
  end
  
  def update
    @room = Room.find(params[:room_id])
    error = false
    
    begin
      @reservation = Reservation.find(params[:id])
      @reservation.assign_attributes(params[:reservation])
      @reservation.author = current_user if params[:assign_to_me]
      @reservation.start = DateTime.strptime(params[:reservation][:start_string], DATETIME_FORMAT) - DateTime.local_offset
      @reservation.end = DateTime.strptime(params[:reservation][:end_string], DATETIME_FORMAT) - DateTime.local_offset
      
      error = !@reservation.save
    rescue ArgumentError
      @reservation.errors.add(:start_string,"")
      @reservation.errors.add(:end_string,"")
      error = true
    end
    
    if error
      render action: "edit"
    else
      flash[:notice] = "Reservation #{@reservation.summary.html_safe} was updated!"
      redirect_to @reservation.room
    end
  end
  
  def find
    @reservation = Reservation.new
    @rooms = Room.all.insert(0, Room.new(name: "--no particular room--", id: nil))
  end
  
  def search
    room = params[:reservation].delete(:room)
    @reservation = Reservation.new(params[:reservation])
    search = @reservation
    search.room_id = room
    
    if search.summary.empty? && search.start_string.empty? && search.end_string.empty? && search.description.empty?
      flash[:error] = "Enter some search parameters first!"
      
      @rooms = Room.all.insert(0, Room.new(name: "--no particular room--", id: nil))
      render action: "find"
    else
      begin
        search.start = DateTime.strptime(params[:reservation][:start_string], DATETIME_FORMAT) - DateTime.local_offset - 1.minute unless search.start_string.empty?
        search.end = DateTime.strptime(params[:reservation][:end_string], DATETIME_FORMAT) - DateTime.local_offset + 1.minute unless search.end_string.empty?
       
        if search.start_string.empty? || search.end_string.empty? || (search.start <= search.end)
          @reservations = Reservation.order("start ASC")
        
          @reservations = @reservations.where("LOWER(summary) LIKE LOWER(?)", '%' + search.summary + '%') unless search.summary.empty?
          @reservations = @reservations.where("LOWER(description) LIKE LOWER(?)", '%' + search.description + '%') unless search.description.empty?
          @reservations = @reservations.where("start >= ?", search.start.to_s(:db)) unless search.start_string.empty?
          @reservations = @reservations.where("end <= ?", search.end.to_s(:db)) unless search.end_string.empty?
          @reservations = @reservations.where("room_id = ?", search.room_id) unless search.room_id == nil
        else
          @reservation.errors.add(:start_string, "must be before end")
          @reservation.errors.add(:end_string, "must be after start")
          
          @rooms = Room.all.insert(0, Room.new(name: "--no particular room--", id: nil))
          render action: "find"
        end
        
      rescue ArgumentError
        @reservation.errors.add(:start_string,"")
        @reservation.errors.add(:end_string,"")
        
        @rooms = Room.all.insert(0, Room.new(name: "--no particular room--", id: nil))
        render action: "find"
      end
      
    end
    
  end
end
