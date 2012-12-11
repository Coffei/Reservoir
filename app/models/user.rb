class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :authentication_keys => [:login]
         
  has_many :reservations, foreign_key: :author_id
  # Setup accessible (or protected) attributes for your model
  attr_accessible :login, :password, :password_confirmation, :remember_me, :email, :name
  # attr_accessible :title, :body
  attr_accessor :skip_password_validation
  
  
  validates :login, uniqueness: true, presence: true, length: { maximum: 50 }
  validates :name, length: { maximum: 100 }
  validates :email, format: { :with => /(\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z)?/i }
  
  validate :password_equality
  
  def password_equality
    unless @skip_password_validation
      if @password.nil? || @password.empty? 
        errors.add(:password, "cannot be empty")
      elsif(@password != @password_confirmation)
        errors.add(:password, "passwords must be the same.")
        errors.add(:password_confirmation, "")
      end
    end
  end
  
  def email_required?
    false
  end
  
  def as_json
    {
      :id => self.id,
      :login => self.login
    }
  end
end
