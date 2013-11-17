class App
  module Views
    class New < Layout
      def paste
        @paste.content unless @paste.nil?
      end

      def filename
        @paste.filename unless @paste.nil? or @paste.filename.nil?
      end
    end
  end
end
