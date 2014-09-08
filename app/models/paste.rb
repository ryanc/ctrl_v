require 'sequel'
require 'radix62'

# Paste model
class Paste < Sequel::Model(:paste)
  plugin :timestamps
  plugin :boolean_readers
  plugin :validation_helpers
  plugin :string_stripper

  many_to_one :user

  attr_reader :expires

  def validate
    super
    validates_presence :content, message: Sequel.lit("The paste cannot be blank.")
    validates_includes [-1, 0, 3600, 86400, 604800, 2592000], :expires, :allow_blank => true
  end

  dataset_module do
    def not_expired
      where(one_time: false).where{Sequel.expr(expires_at: nil) | (expires_at > Time.now)}
    end

    def recent
      order(:created_at).reverse
    end
  end

  def highlighted=(h)
    super(false) if [nil, false].include?(h)
  end

  def after_create
    update(:id_b62 => Radix62.encode62(id))
    super
  end

  def owner?(user)
    !!user && user_id == user.id
  end

  def increment_view_count
    self.view_count += 1
    save
  end

  def expired?
    (one_time? && view_count > 1) || (!!expires_at && expires_at <= Time.now)
  end

  def expires=(expires)
    expires = expires.to_i
    case expires
    when -1
      self.one_time = true
    when *[3600, 86400, 604800, 2592000]
      self.expires_at = Time.now + expires
    else
      self.one_time = false
      self.expires_at = nil
    end
    @expires = expires
  end

  def self.remove_expired
    where(one_time: true).where{view_count >= 2}.or{expires_at <= Time.now}.delete
  end
end
