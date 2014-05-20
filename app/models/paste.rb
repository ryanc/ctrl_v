require 'sequel'
require 'radix62'

module Models
  class Paste < Sequel::Model(:paste)
    plugin :timestamps
    plugin :boolean_readers

    many_to_one :content
    many_to_one :user

    def highlighted=(h)
      if [nil, false].include?(h)
        super(false)
      end
    end

    def highlight?
      self.highlight
    end

    def content=(content)
      content = Content.new(:content => content)

      # Check if the content already exists in the database. Store only one
      # record if it does exist.
      content_id = Content.where(:digest => content.digest).get(:id)

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
end
