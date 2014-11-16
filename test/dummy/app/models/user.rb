class User < ActiveRecord::Base
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  
  validates :name, presence: true
  validates :name, length: { minimum: 2 }
  validates :name, length: { maximum: 10 }
  validates :email,
            presence: true,
            format: { with: VALID_EMAIL_REGEX,
                      message: "Not valid format" },
            length: { maximum: 10,
                      message: "Not valid length" }
end
