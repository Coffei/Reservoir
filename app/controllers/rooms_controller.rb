class RoomsController < ApplicationController
  
  before_filter :authenticate_user!, except: [:index, :show]
  
  
  def index
    @rooms = Room.all
  end
  
  def destroy
    room = Room.find(params[:id])
    
    room.destroy
    
    redirect_to rooms_path
    flash[:info] = "Room #{room.name} was deleted."
  end
  
  def new
    @room = Room.new
  end
  
  def create
    @room = Room.new(params[:room])
    if @room.save
      flash[:info] = "Room #{@room.name} was created."
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
      flash[:info] = "Room #{@room.name} was updated."
      redirect_to @room
    else
      render action: "edit"
    end
  end
  
  def show
    @room = Room.find(params[:id])
    @reservations = Reservation.of(@room).between(Time.now, 14.days.from_now).order("start ASC")
    @reservation = Reservation.new
  end
end
