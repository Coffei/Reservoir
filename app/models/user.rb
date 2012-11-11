class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :authentication_keys => [:login]
  has_many :reservations
  # Setup accessible (or protected) attributes for your model
  attr_accessible :login, :password, :password_confirmation, :remember_me, :email, :name
  # attr_accessible :title, :body
  
  validates :login, uniqueness: true, presence: true, length: { maximum: 50 }
  validates :name, length: { maximum: 100 }
  validates :email, format: { :with => /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i }
  
  def email_required?
    false
  end
end
