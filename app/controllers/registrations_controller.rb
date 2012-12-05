class RegistrationsController < Devise::RegistrationsController
  
  append_before_filter :authenticate_scope!, only: [:edit_password, :edit, :udpate, :destroy] 
  
  def update
    @user = User.find(current_user.id)
    password_changed = params[:user][:password] &&!params[:user][:password].empty?
    
    success = if password_changed #update password
      @user.password = params[:user][:password]
      @user.password_confirmation = params[:user][:password_confirmation]
      if current_user.valid_password?(params[:user][:current_password])
        @user.save
      else
        @user.errors.add(:current_password, "doesn't match")
        false
      end
    else #update user
      @user.skip_password_validation = true
      
      @user.update_without_password(params[:user])
    end
    
    
    if password_changed
      flash[:notice] = "Password was successfuly changed." if success
      render action: "edit_password"
    else 
      flash[:notice] = "User was updated." if success
      render action: "edit"
    end
    
   sign_in @user, bypass: true if success
    
  end
  
  def edit_password
    render :edit_password
  end
  
  def show
    @user = User.find(params[:id])
  end
end