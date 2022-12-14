require 'sequel'
require 'bcrypt'
require 'securerandom'

class Sequel::Model
  def validates_password_confirmation(password)
    errors.add(:password_confirmation, 'The passwords must match.') unless send(password) == send('password_confirmation')
  end
end

# User model
class User < Sequel::Model(:user)
  plugin :timestamps
  plugin :validation_helpers
  plugin :boolean_readers
  plugin :string_stripper

  attr_reader :password
  attr_accessor :password_confirmation

  one_to_many :pastes

  def password=(password)
    @password = password
    self.password_hash = BCrypt::Password.create(password)
  end

  def authenticate(password)
    password_hash = BCrypt::Password.new(self.password_hash)
    password_hash == password
  end

  def validate
    super
    validates_presence :username, message: 'The username cannot be blank.'
    validates_presence :email, message: 'The email address cannot be blank.'
    validates_presence :password, message: 'The password cannot be blank.' if new?
    validates_presence :password_confirmation, message: 'The password confirmation cannot be blank.' if new?
    validates_unique :username, message: 'The username is already taken.'
    validates_unique :email, message: 'The email address has already been used.'
    validates_password_confirmation :password if new?
  end

  def generate_activation_token
    self.activation_token = SecureRandom.urlsafe_base64
  end

  def generate_password_reset_token
    self.password_reset_token = SecureRandom.urlsafe_base64
    self.password_reset_token_generated_at = Time.now
  end

  def before_save
    generate_activation_token if new?
  end

  def password_reset_token_expired?
    t = Time.now
    t > (password_reset_token_generated_at + 1800)
  end

  def clear_password_reset_token
    self.password_reset_token = nil
    self.password_reset_token_generated_at = nil
  end
end
