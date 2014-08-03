require 'sequel'
require 'radix62'

# Paste model
class Paste < Sequel::Model(:paste)
  plugin :timestamps
  plugin :boolean_readers
  plugin :validation_helpers

  many_to_one :user

  def validate
    super
    validates_presence :content, message: Sequel.lit("The paste cannot be blank.")
  end

  dataset_module do
    def active
      where(active: true).where(spam: false)
    end

    def recent
      order(:created_at).reverse
    end
  end

  def highlighted=(h)
    super(false) if [nil, false].include?(h)
  end

  def highlight?
    self.highlight
  end

  def after_create
    update(:id_b62 => Radix62.encode62(id))
    super
  end

  def owner?(user)
    user && user_id == user.id
  end
end
