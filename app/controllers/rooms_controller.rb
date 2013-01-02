class RoomsController < ApplicationController
  
  before_filter :authenticate_user!, except: [:index, :show]
  
  
  def index
    @rooms = Room.all
    
    respond_to do |format|
      format.html
      format.json { render json: @rooms }
    end
  end
  
  def destroy
    room = Room.find(params[:id])
    
    room.reservations.destroy_all
    room.destroy
    
    redirect_to rooms_path
    flash[:info] = "Room #{room.name.html_safe} was deleted."
  end
  
  def new
    @room = Room.new
  end
  
  def create
    @room = Room.new(params[:room])
    if @room.save
      flash[:info] = "Room #{@room.name.html_safe} was created."
      redirect_to @room
    else
      render action: "new"
    end
    
  end
  
  def edit
    @room = Room.find(params[:id])
  end
  
  def update
    @room = Room.find(params[:id])
    
    if(@room.update_attributes(params[:room]))
      flash[:info] = "Room #{@room.name.html_safe} was updated."
      redirect_to @room
    else
      render action: "edit"
    end
  end
  
  def show
    @room = Room.find(params[:id])
    @next_reservation = Reservation.of(@room).between(Time.now, 14.days.from_now).order("\"start\" ASC").first
    @reservation = Reservation.new
    
    respond_to do |format|
      format.html
      format.json { render json: @room }
    end
  end
end
