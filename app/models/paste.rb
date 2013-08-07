require "sequel"
require "radix62"

module Models
  class Paste < Sequel::Model(:paste)
    plugin :timestamps
    plugin :boolean_readers

    many_to_one :content
    many_to_one :user

    def filename
      filename = super
      filename.nil? ? "#{self.id}.txt" : filename
    end

    def highlight?
      self.highlight
    end

    def content=(content)
      # Strip extra whitespace.
      content.strip!

      # Replace CRLF with LF.
      content.gsub! /\r\n?/, "\n"

      # Check if the content already exists in the database. Store only one
      # record if it does exist.
      digest = Digest::MD5.hexdigest(content.to_s)
      content_id = Content.where(:digest => digest).get(:id)
      unless content_id.nil?
        self.content_id = content_id
      else
        super(Content.create(:content => content.to_s))
      end
    end

    def after_create
      self.id_b62 = Radix62.encode62(self.id)
      self.save
      super
    end
  end
end
