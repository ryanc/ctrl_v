require 'sequel'
require 'radix62'

# Paste model
class Paste < Sequel::Model(:paste)
  plugin :timestamps
  plugin :boolean_readers

  many_to_one :content
  many_to_one :user

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

  def content=(content)
    content = Content.new(content: content)

    # Check if the content already exists in the database. Store only one
    # record if it does exist.
    content_id = Content.where(digest: content.digest).get(:id)

    # Create the content if it does not exist.
    if content_id.nil?
      content.save
      content_id = content.id
    end

    self.content_id = content_id
  end

  def after_create
    self.id_b62 = Radix62.encode62(self.id)
    self.save
    super
  end

  def owner?(user)
    user && user_id == user.id
  end
end
