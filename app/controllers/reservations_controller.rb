class ReservationsController < ApplicationController
  before_filter :authenticate_user!, except: [:index, :show]
  DATETIME_FORMAT = "%m/%d/%Y %H:%M"
  
  def create
    @room = Room.find(params[:room_id])
    
    error = false
    
    begin
      @reservation = Reservation.new(params[:reservation])
      @reservation.room = @room
      @reservation.author = current_user
      @reservation.start = DateTime.strptime(params[:reservation][:start_string], DATETIME_FORMAT)
      @reservation.end = DateTime.strptime(params[:reservation][:end_string], DATETIME_FORMAT)
    
      error = !@reservation.save
    rescue ArgumentError
      @reservation.errors.add(:start_string,"")
      @reservation.errors.add(:end_string,"")
      error = true
    end
    
    if error
      render action: "new"
    else
      flash[:notice] = "Reservation #{@reservation.summary} was created!"
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
    flash[:notice] = "Reservation #{reservation.summary} was deleted!"
  end
  
  def edit
    @room = Room.find(params[:room_id])
    @reservation = Reservation.find(params[:id])
    @reservation.start_string = @reservation.start.strftime(DATETIME_FORMAT)
    @reservation.end_string = @reservation.end.strftime(DATETIME_FORMAT)
  end
  
  def update
    @room = Room.find(params[:room_id])
    error = false
    
    begin
      @reservation = Reservation.find(params[:id])
      @reservation.assign_attributes(params[:reservation])
      @reservation.author = current_user if params[:assign_to_me]
      @reservation.start = DateTime.strptime(params[:reservation][:start_string], DATETIME_FORMAT)
      @reservation.end = DateTime.strptime(params[:reservation][:end_string], DATETIME_FORMAT)
      
      error = !@reservation.save
    rescue ArgumentError
      @reservation.errors.add(:start_string,"")
      @reservation.errors.add(:end_string,"")
      error = true
    end
    
    if error
      render action: "edit"
    else
      flash[:notice] = "Reservation #{@reservation.summary} was updated!"
      redirect_to @reservation.room
    end
  end
end
