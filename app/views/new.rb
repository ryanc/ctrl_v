class App
  module Views
    class New < Layout
      def paste
        @paste.content unless @paste.nil?
      end
    end
  end
end
